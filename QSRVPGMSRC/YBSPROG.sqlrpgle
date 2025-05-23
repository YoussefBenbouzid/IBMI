**free
Ctl-Opt nomain;
/COPY QCOPYSRC,YBICRUD1
EXEC SQL SET OPTION COMMIT = *none;

//--------------------------------
// Aggiunta libro
//--------------------------------
dcl-proc YB_AggiungiLibro export; // Per esportare la procedura
  dcl-pi *n ind;
    nuovoLibro LikeDs(tDsLibro);
  END-PI;
  EXEC SQL
  INSERT INTO YBPROG(IDLIBRO, AUTORE, TITOLO, ANNO, ISBN, DISP)
  VALUES (:nuovoLibro.idLibro,:nuovoLibro.autore,:nuovoLibro.titolo,
  :nuovoLibro.anno,:nuovoLibro.isbn,:nuovoLibro.disp);
  if sqlCode < 0;
    return *off;
  else;
    return *on;
  ENDIF;
END-PROC;

//--------------------------------
// Modifica libro
//--------------------------------
dcl-proc YB_ModificaLibro export;
  dcl-pi *n ind;
    libroModificato LikeDs(tDsLibro);
  END-PI;
  EXEC SQL
  UPDATE YBPROG
  SET
    AUTORE = :libroModificato.autore,
    TITOLO = :libroModificato.titolo,
    ANNO = :libroModificato.anno,
    ISBN = :libroModificato.isbn,
    DISP = :libroModificato.disp
  WHERE
    IDLIBRO = :libroModificato.idLibro;
  if sqlCode < 0 or sqlCode = 100;
    return *off;
  else;
    return *on;
  ENDIF;
END-PROC;

//--------------------------------
// Cancellazione libro
//--------------------------------
dcl-proc YB_CancellaLibro export;
  dcl-pi *n ind;
    libroId char(5);
  END-PI;
  EXEC SQL
  DELETE FROM YBPROG
  WHERE IDLIBRO = :libroId;
  if sqlCode < 0 or sqlCode = 100;
    return *off;
  else;
    return *on;
  ENDIF;
END-PROC;

//--------------------------------
// Ottenimento libro
//--------------------------------
dcl-proc YB_OttieniLibro export;
  dcl-pi *n ind;
    libroId char(5);
    libroOttenuto LikeDs(tDsLibro);
  END-PI;
  clear libroOttenuto;
  EXEC SQL
  SELECT IDLIBRO, AUTORE, TITOLO, ANNO, ISBN, DISP
  INTO :libroOttenuto
  FROM YBPROG
  WHERE IDLIBRO = :libroId;
  if sqlCode < 0 or sqlCode = 100;
    return *off;
  endif;
  return *on;
END-PROC;
