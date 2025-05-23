       dcl-ds tDsCrud qualified template;
         opType char(1);
         id char(5);
       end-ds;

       dcl-pr YBRCRUD extpgm('YBRCRUD');
         *n LikeDs(tDsCrud);
       end-pr;
