       dcl-ds tDsLibro qualified template;
         idLibro char(5);
         autore char(10);
         titolo char(15);
         anno char(4);
         isbn char(13);
         disp char(2);
       END-DS;

       dcl-pr YB_AggiungiLibro ind;
         *n LikeDs(tDsLibro);
       END-PR;

       dcl-pr YB_ModificaLibro ind;
         *n LikeDs(tDsLibro);
       END-PR;

       dcl-pr YB_CancellaLibro ind;
         *n char(5);
       END-PR;

       dcl-pr YB_OttieniLibro ind;
          *n char(5);
          *n LikeDs(tDsLibro);
       END-PR;  
