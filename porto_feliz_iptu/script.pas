{
   PROJETO: CARNÊ IPTU --- PREFEITURA PORTO FELIZ
   DATA: 25/11/2019
   DESENVOLVEDOR: VINICIUS VERAS
   BOLETO DE COBRANÇA - IPTU
   SCRIPT DE IMPORTAÇÃO
}

iCont := 0;


//INICIO DE LEITURA
While ReadLn(S) <> EOF do
Begin


nParcelas := FloatToInt(GetFloat(S,2477,2));

IF (T_PARCELAS = nParcelas) then
Begin

IF((nParcelas >= 1) and (nParcelas <= 10)) then
Begin

      iCont := iCont + 1;

      //VARIAVEIS QUE SÃO COMPARTILHADAS EM MAIS DE 1 PAGINA, SEJA: CAPA. ESPELHO, PARCELA E ETC..
      //ASSIM EVITO REDUNDANCIA NO CÓDIGO, MANTENDO O MESMO MANUTENÍVEL

      global_Codigo_Reduzido      := TrimStr(GetString(S,1,10));
      global_Matricula            := TrimStr(GetString(S,11,12));
      global_Exercicio            := TrimStr(GetString(S,23,4));
      global_Ins_Imobiliaria      := TrimStr(GetString(S,27,30));
      global_Proprietario         := TrimStr(GetString(S,157,60));


   global_Proprietario_CNPJ    := '';

   IF(TrimStr(GetString(S,217,18)) <> '') Then
    Begin 
        global_Proprietario_CNPJ    := 'CPF/CNPJ: ' + TrimStr(GetString(S,217,18));
    End;
    

   global_Compromissario       := TrimStr(GetString(S,235,100));



    global_Compromissario_CNPJ  := '';

    IF(TrimStr(GetString(S,335,18)) <> '') Then
     Begin
          global_Compromissario_CNPJ  := 'CPF/CNPJ: ' + TrimStr(GetString(S,335,18));
     End;
 


   


//--------------------------   END CORRESPONDENCIA  ----------------------

   //LIMPANDO O LIST DE ENDERECO DE CORRESPONDENCIA

   global_C_End   := '';
   global_C_End   := MultLineClear(global_C_End);


      //VARIAVEIS AUXILIARES
      end_c := TrimStr(GetString(S,353,75)) + ', ' +  TrimStr(GetString(S,428,20));
      cpl_c := '';


     //Apartamento
     if(TrimStr(GetString(S,633,16)) <> '') then
       begin 
           
         cpl_c := cpl_c  + ' ' + TrimStr(GetString(S,633,16));
      
       end;

      //Andar
      if(TrimStr(GetString(S,616,17)) <> '') then
       begin 
           
         cpl_c := cpl_c  + ' ' + TrimStr(GetString(S,616,17));
      
       end;

      //Complemento
      if(TrimStr(GetString(S,498,57)) <> '') then
       begin 
           
         cpl_c := cpl_c + ' - ' + TrimStr(GetString(S,498,57));
      
       end;
     
     
      //Endereço, número, apto, andar e complemento  
      global_C_End   := MultLineAdd(global_C_End, (end_c + cpl_c));



     //Bairro
      if(TrimStr(GetString(S,448,50)) <> '') then
       begin 
           
         global_C_End   := MultLineAdd(global_C_End, TrimStr(GetString(S,448,50)));
      
       end;


    //CIDADE e UF
    global_C_End   := MultLineAdd(global_C_End, (TrimStr(GetString(S,564,50)) + '/' + TrimStr(GetString(S,614,2)))); 
     
      
    //CEP
    global_C_End   := MultLineAdd(global_C_End, TrimStr(GetString(S,555,9)));


//---------------------- FIM END CORRESPONDENCIA -------------------------------


//----------------------  END IMÓVEL  --------------------------------------------
    
   //LIMPANDO O LIST DE ENDERECO DE IMÓVEL

   global_I_End := '';
   global_I_End := MultLineClear(global_I_End);


      //VARIAVEIS AUXILIARES
      end_i := TrimStr(GetString(S,649,10)) + ' ' +  TrimStr(GetString(S,666,50)) + ', ' + TrimStr(GetString(S,716,10));
      cpl_i := '';


     //Apartamento
     if(TrimStr(GetString(S,800,16)) <> '') then
       begin 
           
         cpl_i := cpl_i  + ' ' +  TrimStr(GetString(S,800,16));
      
       end;

      //Andar
      if(TrimStr(GetString(S,783,17)) <> '') then
       begin 
           
         cpl_i := cpl_i  + ' ' + TrimStr(GetString(S,783,17));
      
       end;

      //Complemento
      if(TrimStr(GetString(S,726,57)) <> '') then
       begin 
           
         cpl_i := cpl_i + ' - ' + TrimStr(GetString(S,726,57));
      
       end;
     
     
      //Endereço, número, apto, andar e complemento  
      global_I_End   := MultLineAdd(global_I_End, (end_i + cpl_i));



     //Bairro
      if(TrimStr(GetString(S,823,50)) <> '') then
       begin 
           
         global_I_End   := MultLineAdd(global_I_End, TrimStr(GetString(S,823,50)));
      
       end;


    //CIDADE e UF
    global_I_End   := MultLineAdd(global_I_End, (TrimStr(GetString(S,873,50)) + '/' + TrimStr(GetString(S,923,2)))); 
     
      
    //CEP
    global_I_End   := MultLineAdd(global_I_End, TrimStr(GetString(S,925,9)));

 
    global_Quadra    := TrimStr(GetString(S,984,10));
    global_Lote      := TrimStr(GetString(S,994,20));


//----------------------  FIM END IMÓVEL  --------------------------------------------


//------------------------  ORDENAÇÃO --------------------------------------

     global_Ordenacao := GetString(S,555,9) + MultLineItem(global_C_End, 0) + global_Ins_Imobiliaria;

//--------------------------  CAPA --------------------------------------


IF(G_CAPA = 1) THEN
BEGIN

   //**************   GRAVANDO ********************************
    ClearFields(CAPA,REC1);

    
    sSoNum := '0123456789';
    sCepTmp := Replace(GetString(S,555,9), '-', '');
    bGrava := False;
    sCepLimpo := '';
    iTamCep := Length(sCepTmp);

     for i := 1 TO iTamCep do
      begin
        for x := 1 TO 10 do
        begin
          if copy(sCepTmp,i,1) = copy(sSoNum,x,1) then bGrava := True;
        end;

        if bGrava then sCepLimpo := sCepLimpo + copy(sCepTmp,i,1);

        bGrava := False;

      end; 


      // SE ELE TIRAR A SUJEIRA DO CEP E FICAR MENOR QUE 8 BYTES
      // COMPLETO COM ZEROS A DIREITA, SO PRA NAO DAR ERRO
      while Length(sCepLimpo) < 8 do
      begin
        sCepLimpo := sCepLimpo+'0';
      end;

    CAPA.REC1.CEPNET := sCepLimpo;
  
    CAPA.REC1.NOMEARQ    := RetornaNomeArqEntrada(0);
    CAPA.REC1.PROP       := global_Proprietario;
    CAPA.REC1.PROP_CNPJ  := global_Proprietario_CNPJ;

     //Endereço Entrega
     FOR X := 0 TO 4 DO
      BEGIN

         CAPA.REC1.END_ENTREG[X+1] := MultLineItem(global_C_End, X);
 
      END;
    

     BeginPage(CAPA);
       WriteRecord(CAPA,REC1);
     EndPage(CAPA);


     //LIMPANDO Endereço Entrega
     FOR X := 0 TO 4 DO
      BEGIN

         CAPA.REC1.END_ENTREG[X+1] := '';
 
      END;

   //************** END - GRAVACAO ********************************


END;

//-------------------------- END - CAPA ------------------------


//-------------------------- PUBLICIDADE -----------------
IF(G_PUBLICID = 1) THEN
BEGIN 

  ClearFields(PUBLICIDAD,REC1);
  
   BeginPage(PUBLICIDAD);
    WriteRecord(PUBLICIDAD,REC1);
   EndPage(PUBLICIDAD);

END;

//---------------------------- END PUBLICIDADE ---------------------

//----------------------------  ESPELHO  ---------------------------
     

IF(G_ESPELHO = 1) THEN
BEGIN

     //VARIAVEIS EXCLUSIVAS
     espelho_FracaIdeal              := TrimStr(GetString(S,2327,6));
     espelho_Testada                 := GetFloat(S,1079,12)/100;
     espelho_Area_Terreno            := GetFloat(S,1067,12)/100;
     espelho_Area_Construcao         := GetFloat(S,1151,12)/100;
     espelho_Valor_Venal_Terreno     := GetFloat(S,1127,12)/100;
     espelho_Valor_Venal_Construcao  := GetFloat(S,1163,12)/100;          
     espelho_Valor_Venal_Imovel      := GetFloat(S,1355,12)/100;   
     espelho_Aliquota                := GetFloat(S,1059,8)/100;   
     espelho_Imposto_Total           := GetFloat(S,2441,12)/100; 
     espelho_IPTU_Total              := GetFloat(S,2453,12)/100; 
     espelho_TAXA_Total              := GetFloat(S,2465,12)/100; 


   //**************   GRAVANDO ********************************

     ClearFields(ESPELHO,REC1);

     //Globais
     ESPELHO.REC1.NPARCELAS    := nParcelas;
     ESPELHO.REC1.CADASTRO     := global_Codigo_Reduzido;
     ESPELHO.REC1.MATRICULA    := global_Matricula;
     ESPELHO.REC1.EXERCICIO    := global_Exercicio;
     ESPELHO.REC1.INSCRICAO    := global_Ins_Imobiliaria;
     ESPELHO.REC1.PROP         := global_Proprietario;
     ESPELHO.REC1.PROP_CNPJ    := global_Proprietario_CNPJ;
     ESPELHO.REC1.COMPROM      := global_Compromissario;
     ESPELHO.REC1.COMPR_CNPJ   := global_Compromissario_CNPJ;

 

     //Endereço Imóvel

     FOR X := 0 TO 4 DO
      BEGIN

         ESPELHO.REC1.END_IMOV[X+1] := MultLineItem(global_I_End, X);
 
      END;
   
     ESPELHO.REC1.QUADRA       := global_Quadra;
     ESPELHO.REC1.LOTE         := global_Lote;



     //TABELA DE LANÇAMENTO

     ESPELHO.REC1.ALIQUOTA     := espelho_Aliquota;
     ESPELHO.REC1.TESTADA      := espelho_Testada;
     ESPELHO.REC1.VL_VENAL_T   := espelho_Valor_Venal_Terreno;
     ESPELHO.REC1.AREA_CONST   := espelho_Area_Construcao;
     ESPELHO.REC1.V_V_T_CONS   := espelho_Valor_Venal_Construcao;
     ESPELHO.REC1.V_V_T_IMOV   := espelho_Valor_Venal_Imovel;
     ESPELHO.REC1.AREA_TERRE   := espelho_Area_Terreno;
     ESPELHO.REC1.FRACAO_IDE   := espelho_FracaIdeal;
     ESPELHO.REC1.IPTU_TOTAL   := espelho_IPTU_Total;  
     ESPELHO.REC1.TAXAS_TOTA   := espelho_TAXA_Total;
     ESPELHO.REC1.TOTAL_IMPO   := espelho_Imposto_Total;
     ESPELHO.REC1.VL_UNICA     := GetFloat(S, 3609, 12)/100;
        



     BeginPage(ESPELHO);
       WriteRecord(ESPELHO,REC1);
     EndPage(ESPELHO); 

    
     FOR X := 0 TO 4 DO
      BEGIN

         ESPELHO.REC1.END_IMOV[X+1] := '';
 
      END;


   //************** END - GRAVACAO ********************************

END;


//---------------------------- END - ESPELHO -----------------------------------



//---------------------------------  ÚNICA E PARCELAS --------------------------------

IF(G_PARCELA = 1) THEN
BEGIN
  
//Parcelas
   inic_Parc    := 3609;
   size_Parc    := 12;

//Vencimento
  inic_Venc     := 3793;
  size_Venc     := 8;

//Nosso Número
  inic_NossoNum := 6059;
  size_NossoNum := 20;

//Código de Barras 
   inic_CodeBar := 6427;
   size_CodeBar := 44;

//Linha digitável
   inic_LinDig  := 7159;
   size_LinDig  := 58;  


  FOR X := 0 TO (nParcelas + 1) do 
   BEGIN
        
        IF( X <> 1) THEN
         BEGIN 

           ClearFields(PARC,REC1);

           PARC.REC1.CADASTRO    := global_Codigo_Reduzido;
           PARC.REC1.EXERCICIO   := global_Exercicio;
           PARC.REC1.INSCRICAO   := global_Ins_Imobiliaria;
           PARC.REC1.PROP        := global_Proprietario;
           PARC.REC1.PROP_CNPJ   := global_Proprietario_CNPJ;

           FOR Y := 0 TO 4 DO
            BEGIN
              PARC.REC1.END_ENTREG[Y+1] := MultLineItem(global_C_End, Y);
            END;
 

            PARC.REC1.VL_DOC    := GetFloat(S, inic_Parc, 12)/100;
            PARC.REC1.VENC      := GetString(S, (inic_Venc + 6), 2) + '/' + GetString(S, (inic_Venc + 4), 2) + '/' + GetString(S, inic_Venc, 4);
            PARC.REC1.NOSSO_NUM := FormatFloat(GetFloat(S, inic_NossoNum, 10),'9999') + GetString(S, inic_NossoNum + 10, 10);
            PARC.REC1.CODBAR    := GetString(S, inic_CodeBar, 44);
            PARC.REC1.LINHA_DIG := GetString(S, inic_LinDig, 58);

            PARC.REC1.AVISO     := GetString(S, (inic_NossoNum + 13), 7);


            //única
            IF(x = 0) Then
            Begin
                 PARC.REC1.EHUNICA := 1;
                 PARC.REC1.PARCELA := 'ÚNICA';
                 PARC.REC1.MSGM    := 'FINALIDADE: IPTU 2020 - PARCELA: ÚNICA';
                 PARC.REC1.MSGM_2  := 'PARCELA ÚNICA JÁ COM DESCONTO DE 5%';
                PARC.REC1.MSG_3   := 'NÃO RECEBER APÓS O VENCIMENTO.';
            End
            Else
             Begin
                 PARC.REC1.EHUNICA := 0;
                 PARC.REC1.PARCELA := FormatNumeric(X-1,'00') + '/' + FormatNumeric(nParcelas, '00');  
                 PARC.REC1.MSGM    := 'FINALIDADE: IPTU 2020 - PARCELA: ' + FormatNumeric(X-1,'00');
                 PARC.REC1.MSGM_2  := 'APÓS O VENCIMENTO COBRAR MULTA DE 2% E JUROS DE 1% AO MÊS';
                 PARC.REC1.MSG_3   := 'NÃO PAGAR APÓS 28/12/2020';

             End;
          

             




            BeginPage(PARC);
              WriteRecord(PARC,REC1);
            EndPage(PARC); 


            FOR Z := 0 TO 4 DO
             BEGIN
               PARC.REC1.END_ENTREG[Z+1] := '';
             END;

   
        END;

           //Atualizando posições 
           inic_Parc     := inic_Parc     + size_Parc;
           inic_Venc     := inic_Venc     + size_Venc;
           inic_NossoNum := inic_NossoNum + size_NossoNum;
           inic_CodeBar  := inic_CodeBar  + size_CodeBar;
           inic_LinDig   := inic_LinDig   + size_LinDig;

END;

END;

//--------------------------- FIM ÚNICA  -----------------------------------


//---------------------- CONTRA CAPA ---------------------------------

IF(G_CONTRACA = 1) THEN
BEGIN 


  ClearFields(CONTRA_CAP,REC1);


  BeginPage(CONTRA_CAP);
   WriteRecord(CONTRA_CAP,REC1);
  EndPage(CONTRA_CAP);

END;

//-------------------- END CONTRACAPA  ----------------------------------


 Markup(global_Ordenacao);

End;

End;

END;
Convert(3,true,false,true,30,false);
