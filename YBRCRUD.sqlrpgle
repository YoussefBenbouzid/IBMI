**free
//------------------------------
//     Specifiche iniziali
//------------------------------
ctl-opt dftactgrp(*no) bnddir('YBBPROG');
dcl-f YBDCRUD WORKSTN(*EXT);

dcl-ds dsLibro qualified; // qualified abilita prefisso dsLibro
  idLibro char(5);
  autore char(10);
  titolo char(15);
  anno char(4);
  isbn char(13);
  disp char(2);
END-DS;

/COPY QCOPYSRC,YBICRUD2
/COPY QCOPYSRC,YBICRUD1

dcl-pi YBRCRUD;
  dsEntry likeDs(tDsCrud); // Passo la struttura come parametro
END-PI;

EXEC SQL SET OPTION COMMIT=*NONE; // Per disabilitare il commit

select;
  when dsEntry.opType = 'U';
    *in21 = *on;
    *in23 = *on;
    *in24 = *on;
    *in25 = *off;
    WIDLIBRO = dsEntry.id;
    VisualizzaLibro(WIDLIBRO);
  when dsEntry.opType = 'V';
    *in21 = *on;
    *in26 = *on;
    *in23 = *on;
    *in24 = *on;
    *in25 = *on;
    WIDLIBRO = dsEntry.id;
    VisualizzaLibro(WIDLIBRO);
  when dsEntry.opType = 'D';
    *in21 = *on;
    *in26 = *on;
    *in23 = *on;
    *in24 = *off;
    *in25 = *on;
    WIDLIBRO = dsEntry.id;
    VisualizzaLibro(WIDLIBRO);
ENDSL;

doU *inKL = *on;
  exfmt WIN1;
  SELECT;
  when *inKF = *on;
    PopulateLibroDs(WIDLIBRO:WAUTORE:WTITOLO:WANNO:WISBN:WDISP);
    AggiungiLibro(dsLibro);
  when *inKB = *on;
    PopulateLibroDs(WIDLIBRO:WAUTORE:WTITOLO:WANNO:WISBN:WDISP);
    ModificaLibro(dsLibro);
  when *inKQ = *on;
    doU *inKI = *on or *inKQ = *on;
      exfmt WIN2;
      if *inKQ = *on;
        CancellaLibro(WIDLIBRO);
      ENDIF;
    enddo;
  other;
    if WIDLIBRO <> '';
      VisualizzaLibro(WIDLIBRO);
    ENDIF;
  ENDSL;
ENDDO;

*inLR = *on;
return;

//--------------------------------
// Costruttore
//--------------------------------
DCL-PROC PopulateLibroDs;
  dcl-pi *n;
    idLibro char(5);
    autore char(10);
    titolo char(15);
    anno char(4);
    isbn char(13);
    disp char(2);
  END-PI;
  clear dsLibro;
  dsLibro.idLibro = idLibro;
  dsLibro.autore = autore;
  dsLibro.titolo = titolo;
  dsLibro.anno = anno;
  dsLibro.isbn = isbn;
  dsLibro.disp = disp;
END-PROC;

//--------------------------------
// Pulizia campi libro
//--------------------------------
dcl-proc PulisciCampi;
  WAUTORE = '';
  WTITOLO = '';
  WANNO = '';
  WISBN = '';
  WDISP = '';
END-PROC;

//--------------------------------
// Aggiunta libro
//--------------------------------
DCL-PROC AggiungiLibro;
  dcl-pi *n ind;
    nuovoLibro LikeDs(dsLibro);
  END-PI;
  if YB_AggiungiLibro(nuovoLibro);
    PulisciCampi();
    return *on;
  else;
    return *off;
  ENDIF;
END-PROC;

//--------------------------------
// Modifica libro
//--------------------------------
dcl-proc ModificaLibro;
  dcl-pi *n ind;
    libroModificato LikeDs(dsLibro);
  END-PI;
  if YB_ModificaLibro(libroModificato);
    PulisciCampi();
    return *on;
  else;
    return *off;
  ENDIF;
END-PROC;

//--------------------------------
// Cancellazione libro
//--------------------------------
dcl-proc CancellaLibro;
  dcl-pi *n ind;
    id char(5);
  END-PI;
  if YB_CancellaLibro(id);
    // PulisciCampi();
    return *on;
  else;
    return *off;
  ENDIF;
END-PROC;

//--------------------------------
// Visualizzazione libro
//--------------------------------
dcl-proc VisualizzaLibro;
  dcl-pi *n;
    id_inp char(5);
  END-PI;
  // PulisciCampi();
  YB_OttieniLibro(id_inp:dsLibro);
  if *on;
    WIDLIBRO = dsLibro.idLibro;
    WAUTORE = dsLibro.autore;
    WTITOLO = dsLibro.titolo;
    WANNO = dsLibro.anno;
    WISBN = dsLibro.isbn;
    WDISP = dsLibro.disp;
  ENDIF;
END-PROC;
