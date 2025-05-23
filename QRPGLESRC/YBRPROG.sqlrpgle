**free
ctl-opt dftactgrp(*no); // Il programma gira in ILE
dcl-f YBDPROG WORKSTN(*EXT) SFILE(WSFL:SF1SRN); // Includo display e subfile
/COPY ELMPBEN/QCOPYSRC,YBICRUD2
dcl-ds dsCrud LikeDs(tDsCrud);
EXEC SQL SET OPTION COMMIT=*NONE; // Per disabilitare il commit

doU *inKL = *on; // Finché non viene selezionato KL (F12)
  PulisciWSFL();
  CaricaWSFL(PARAM);
  *in51 = *on; // Abilita SFLDSPCTL (controllo subfile)
  if SF1SRN > 0; // Se ci sono record in subfile
    *in52 = *on; // Abilita SFLDSP (visualizzazione subfile)
    SF1SRN = 1;  // Cursore nel primo record
  ENDIF;
  VisualizzaWSFL();
  if *inKF = *on;
    clear dsCrud;
    dsCrud.opType = 'I';
    callP(e) YBRCRUD(dsCrud);
  else;
    GestisciWSFL();
  ENDIF;
ENDDO;

*inLr = *on; // Termina il programma alla fine
return; // Per compilare file RPG

//--------------------------------
// Pulizia subfile
//--------------------------------
dcl-proc PulisciWSFL;
  *in50 = *on;  // Abilita SFLCLR e SFLDLT (cancellazione)
  *in51 = *off; // Disabilita SFLDSPCTL (controllo subfile)
  *in52 = *off; // Disabilita SFLDSP (visualizzazione subfile)
  write WCTL; // Riscrive control file
  *in50 = *off; // Disabilita la cancellazione
  SF1SRN = 0;   // Record number da capo
  clear WSFL; // Pulisce subfile
END-PROC;

//--------------------------------
// Caricamento subfile
//--------------------------------
dcl-proc CaricaWSFL;
  dcl-pi *n;
    id char(5);
  end-pi;

  // Struttura dati coerente al file fisico
  dcl-ds dsLibro qualified; // qualified abilita prefisso dsLibro
    idLibro char(10);
    autore char(10);
    titolo char(15);
    anno char(4);
    isbn char(13);
    disp char(2);
  END-DS;

  // Prelevo i campi dal file fisico
  EXEC SQL
  DECLARE C1 CURSOR FOR
  SELECT IDLIBRO, AUTORE, TITOLO, ANNO, ISBN, DISP
  FROM YBPROG;

  EXEC SQL OPEN C1;
  dow sqlCode = 0 and sqlCode <> 100;
    EXEC SQL FETCH C1 INTO :dsLibro;
    if sqlCode < 0 or sqlCode = 100;
      leave;
    ENDIF;
    WIDLIBRO = dsLibro.idLibro;
    WAUTORE = dsLibro.autore;
    WTITOLO = dsLibro.titolo;
    WANNO = dsLibro.anno;
    WISBN = dsLibro.isbn;
    WDISP = dsLibro.disp;
    SF1SRN +=1; // Incremento il record number
    write(e) WSFL; // Scrivo nel subfile
  ENDDO;
  EXEC SQL CLOSE C1;
END-PROC;

//--------------------------------
// Visualizzazione subfile
//--------------------------------
dcl-proc VisualizzaWSFL;
  write WFOOTER; // Aggiunge il footer, usando OVERLAY
  exfmt WCTL; // Visualizza subfile e accetta input nel control file
END-PROC;

//--------------------------------
// Gestione subfile
//--------------------------------
dcl-proc GestisciWSFL;
  dcl-s i zoned(4:0);
  // dcl-ds dsCrud likeDs(tDsCrud);
  for i = 1 to 9999;
    chain i WSFL;
    if not %found;
      leave;
    ENDIF;
    select;
      when WSEL = '2';
        clear dsCrud;
        dsCrud.opType = 'U';
        dsCrud.id = WIDLIBRO;
        callP(e) YBRCRUD(dsCrud);
      when WSEL = '4';
        clear dsCrud;
        dsCrud.opType = 'D';
        dsCrud.id = WIDLIBRO;
        callP(e) YBRCRUD(dsCrud);
      when WSEL = '5';
        clear dsCrud;
        dsCrud.opType = 'V';
        dsCrud.id = WIDLIBRO;
        callP(e) YBRCRUD(dsCrud);
    ENDSL;
  ENDFOR;
END-PROC;
