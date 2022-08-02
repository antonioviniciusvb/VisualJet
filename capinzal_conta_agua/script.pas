{
   PROJETO: CONTA DE AGUA DE CAPINZAL
   DATA: 26/08/2021
   DESENVOLVEDOR: VINICIUS VERAS
   SCRIPT DE IMPORTAÇÃO
}


 nCount := 0;

//---------- INICIO - HEADER ----------

//As 23 linhas iniciais são para mensagens na página EXTERNA
//Sendo 11 para a mensagem de "significados dos parametros da analise de água"
//E 12 para uma mensagem que irá na parte inferior 
//Capturo elas no list "Ls_Header"

Ls_Header := '';

For X := 1 to 23 do
Begin

  ReadLn(S);

  linha  := TrimStr(S);

  //O tamanho limite do 1º memo é 163 e do 2º é 135
  //Caso alguma linha seja maior que este valor
  //Aborto o script e será necessário atualizar esse código
  if(Length(linha) > 163) and (X < 12) then Abort;

  if(Length(linha) > 135) and (X > 11) then Abort;
 
  Ls_Header := MultLineAdd(Ls_Header, linha);

End;

//---------- FIM - HEADER ----------


//---------- INICIO - GRAVAÇÃO ----------

While (ReadLn(S) <> EOF) And (TrimStr(S) <> '') do
Begin

 nCount := nCount + 1;

 sOrder_Atendimento := '';
 sCod_Ligacao       := '';
 sNome_Consumidor   := '';
 sCod_Rota          := '';
 sEnd_Rua           := '';
 sEnd_Bairro        := '';
 sEnd_Numero_Imovel := '';
 sEnd_Complemento   := '';
 sEnd_Localidade    := '';
 sEnd_CEP           := '';
 sNum_Hidrometro    := '';
 sNome_Inquilino    := '';

 sOrder_Atendimento := GetString(S,129,5);
 sCod_Ligacao       := GetString(S,134,5);
 sNome_Consumidor   := TrimStr(GetString(S,143,30));
 sCod_Rota          := GetString(S,203,3);

 // sEnd_Rua           := TrimStr(GetString(S,212,23));
 sEnd_Rua           := TrimStr(GetString(S,2344,50));
 sEnd_Bairro        := TrimStr(GetString(S,235,25));
 sEnd_Numero_Imovel := TrimStr(GetString(S,290,5));

 if(TrimStr(GetString(S,341,20)) <> '') then
  begin

    sEnd_Complemento   := ' - ' + TrimStr(GetString(S,341,20));

  end;


 sEnd_Localidade    := TrimStr(GetString(S,2053,8)) + ' - SC';
 sEnd_CEP           := 'CEP: 89665-000';

 sNome_Inquilino    := TrimStr(GetString(S,260,30));

 sNum_Hidrometro    := TrimStr(GetString(S,295,12));

//VERIFICA SE HÁ 2 BOLETOS NO REGISTRO
IF(GetFloat(S,466,11) = 0.00) THEN
BEGIN

//---------- INICIO - INTERNA ----------

  ClearFields(INTERNA,REC1);

  INTERNA.REC1.MSG_INF_I[1] := TrimStr(GetString(S,2,60));
  INTERNA.REC1.MSG_INF_I[2] := TrimStr(GetString(S,62,60));

//---------- INICIO - REGIÃO SUPERIOR ----------

  INTERNA.REC1.CONSUMIDOR := sNome_Consumidor + ' - ' + TrimStr(GetString(S,173,30));
  INTERNA.REC1.INQUILINO  := sNome_Inquilino;
  INTERNA.REC1.COD_LIGACA := sCod_Ligacao;
  INTERNA.REC1.HIDROMETRO := sNum_Hidrometro;
  INTERNA.REC1.ENDERECO_1 := sEnd_Rua + ', ' + sEnd_Numero_Imovel + sEnd_Complemento; 
  INTERNA.REC1.ENDERECO_2 := sEnd_Bairro;
  INTERNA.REC1.ENDERECO_3 := sEnd_CEP + ' - ' + sEnd_Localidade;

  INTERNA.REC1.E_RESIDE   := TrimStr(GetString(S,404,2));
  INTERNA.REC1.E_COMER    := TrimStr(GetString(S,406,2));
  INTERNA.REC1.E_INDUSTRI := TrimStr(GetString(S,408,2));
  INTERNA.REC1.E_PUBLI    := TrimStr(GetString(S,410,2));
  INTERNA.REC1.E_SOCIAIS  := TrimStr(GetString(S,412,2));
  INTERNA.REC1.E_PUBLICA  := TrimStr(GetString(S,3109,2));
  INTERNA.REC1.E_ENTIDADE := TrimStr(GetString(S,3111,2));


//---------- FIM - REGIÃO SUPERIOR ----------

//---------- INICIO - TABELA TARIFÁRIA ----------

  INTERNA.REC1.TBO_RES    := FormatFloat(GetFloat(S,666,8),'#.###,##');
  INTERNA.REC1.TBO_COM    := FormatFloat(GetFloat(S,674,8),'#.###,##');
  INTERNA.REC1.TBO_SOCIAL := FormatFloat(GetFloat(S,658,8),'#.###,##');

 ini_Tarifa_Residencial := 477;

 For X := 1 TO 5  do
  Begin

     INTERNA.REC1.TARIFA_R[X] := FormatFloat(GetFloat(S,ini_Tarifa_Residencial,8),'#.###,###');
 
     ini_Tarifa_Residencial := ini_Tarifa_Residencial + 8;

  End;


 ini_Tarifa_Comercial := 517;

 For X := 1 TO 4  do
  Begin

     INTERNA.REC1.TARIFA_C[X] := FormatFloat(GetFloat(S,ini_Tarifa_Comercial,8),'#.###,###');
 
     ini_Tarifa_Comercial := ini_Tarifa_Comercial + 8;

  End;


 ini_Tarifa_Social := 618;

 For X := 1 TO 5  do
  Begin

     INTERNA.REC1.T_SOCIAL[X] := FormatFloat(GetFloat(S,ini_Tarifa_Social,8),'#.###,###');
 
     ini_Tarifa_Social := ini_Tarifa_Social + 8;

  End;

//---------- FIM - TABELA TARIFÁRIA ----------


//---------- INICIO - INFORMAÇÕES DE LEITURA ----------

  INTERNA.REC1.LL_ANTERIO := FormatFloat(GetFloat(S,600,6),'9999');
  INTERNA.REC1.LL_ATUAL   := FormatFloat(GetFloat(S,606,6),'9999');

  INTERNA.REC1.DT_ANTERIO := GetString(S,2043,10);
  INTERNA.REC1.DT_ATUAL   := FormatDate(GetDate(S,327,6),'DD/MM/AAAA');
  INTERNA.REC1.CONSUM_MES := FormatFloat(GetFloat(S,612,4),'9999');
  INTERNA.REC1.DIAS_CONSU := GetString(S,616,2);

//---------- FIM - INFORMAÇÕES DE LEITURA ----------

  INTERNA.REC1.MES_REFERE := GetString(S,1983,2) + '/' + GetString(S,1985,4);
  INTERNA.REC1.DATA_VENC  := FormatDate(GetDate(S,1990,8),'DD/MM/AAAA');
  INTERNA.REC1.VALOR_FATU := FormatFloat(GetFloat(S,549,11)/100,'9.999,99');

  INTERNA.REC1.N_BANCO      := TrimStr(GetString(S,361,23));
  INTERNA.REC1.NUM_BANCO    := TrimStr(GetString(S,333,8));
  INTERNA.REC1.CONTA_C      := TrimStr(GetString(S,1864,15));


//---------- INICIO - VALORES DO BOLETO ----------

  INTERNA.REC1.SEQUENCIAL := GetString(S,1959,12);
  INTERNA.REC1.DIG        := GetString(S,800,2);

  INTERNA.REC1.VL_FATUR_B := FormatFloat(GetFloat(S,1971,12),'9.999,99');

  //Débito em Conta
  If((TrimStr(GetString(S,846,11)) = '***********') and (TrimStr(GetString(S,1921,10)) <> '' )) then
  Begin
   
     INTERNA.REC1.LIN_DIG    := GetString(S,1921,38);

  End
   Else
   Begin

     INTERNA.REC1.LIN_DIG    := GetString(S,846,55);
     INTERNA.REC1.BARCODE    := GetString(S,802,44);


     INTERNA.REC1.PIX        := TrimStr(GetString(S,3113,180));   
     INTERNA.REC1.TXT_PIX    := 'PAGUE COM PIX';
     INTERNA.REC1.SETA       := 'ITEM1';
   End;



//---------- FIM - VALORES DO BOLETO ----------


//---------- INICIO - TABELA DESCRIÇÃO VALORES ----------

 ini_T_D_Tributos   := 904;
 Index_T_D_Tributos := 1;

 For X := 1 TO 8  do
  Begin

     //DESCRIÇÃO DE TRIBUTOS
     If(GetFloat(S,ini_T_D_Tributos + 38, 11) > 0) then 
      Begin
    
      INTERNA.REC1.DESC_SERV[Index_T_D_Tributos] := TrimStr(GetString(S,ini_T_D_Tributos,38));
      INTERNA.REC1.VLR_SERV[Index_T_D_Tributos]  := FormatFloat(GetFloat(S,ini_T_D_Tributos + 38, 11)/100,'9.999,99');
    
      Index_T_D_Tributos := Index_T_D_Tributos + 1;

      End;


      //Atualizando posição
      ini_T_D_Tributos  := ini_T_D_Tributos + 49;
    
  End;


 ini_Cobranca_Terceiros   := 1394;
 Index_Cobranca_Terceiros := 1;
 
 For  Y := 1 TO 3  do
  Begin

      //COBRANÇA TERCEIROS
     If(GetFloat(S,ini_Cobranca_Terceiros + 38, 11) > 0) then 
      Begin

         INTERNA.REC1.COBR_TERCE[Index_Cobranca_Terceiros] := TrimStr(GetString(S,ini_Cobranca_Terceiros, 38));
         INTERNA.REC1.VLR_COB_TE[Index_Cobranca_Terceiros] := FormatFloat(GetFloat(S,ini_Cobranca_Terceiros + 38, 11)/100,'9.999,99');

         Index_Cobranca_Terceiros := Index_Cobranca_Terceiros + 1;

      End;

      //Atualizando posição
      ini_Cobranca_Terceiros  := ini_Cobranca_Terceiros + 49;

  End;


 ini_OutrosServicos   := 1541;
 Index_OutrosServicos := 1;
 
 For Z := 1 TO 6  do
  Begin

     //OUTROS SERVIÇOS
     If(GetFloat(S,ini_OutrosServicos + 38, 11) > 0) then 
      Begin

        INTERNA.REC1.DESC_OU_S[Index_OutrosServicos] := TrimStr(GetString(S, ini_OutrosServicos, 38));
        INTERNA.REC1.VLR_OU_S[Index_OutrosServicos]  := FormatFloat(GetFloat(S,ini_OutrosServicos + 38, 11)/100,'9.999,99');

        Index_OutrosServicos := Index_OutrosServicos + 1;

      End;

      //Atualizando posição
      ini_OutrosServicos  := ini_OutrosServicos + 49;

  End;


  //MULTAS E JUROS

  INTERNA.REC1.D_MULTA  := TrimStr(GetString(S,1296,38));
  INTERNA.REC1.D_MULTA1 := TrimStr(GetString(S,1345,38));

  INTERNA.REC1.VLR_MULTA  := GetFloat(S,1334,11)/100;
  INTERNA.REC1.VLR_MULTA1 := GetFloat(S,1383,11)/100;

  
//---------- FIM - TABELA DESCRIÇÃO VALORES ----------



//---------- INICIO - HISTORICO DE CONSUMO ----------

  //CONSUMO MÉDIO
  INTERNA.REC1.CONSUMO_M  := FormatFloat(GetFloat(S,310,5),'9999');

  //CONSUMO ANTERIOR

  INTERNA.REC1.CONSUMO[1] := TrimStr(GetString(S,564,5));
  INTERNA.REC1.CONSUMO[2] := TrimStr(GetString(S,572,5));
  INTERNA.REC1.CONSUMO[3] := TrimStr(GetString(S,580,5));

  //MES REF. ANTERIOR

  INTERNA.REC1.MES_REF[1] :=  TrimStr(GetString(S,1882, 5));
  INTERNA.REC1.MES_REF[2] :=  TrimStr(GetString(S,1887, 5));
  INTERNA.REC1.MES_REF[3] :=  TrimStr(GetString(S,1892, 5));

  ini_MesRef := 2299;

  ini_Consumo := 2254;

  For Index_MRef_Cons := 4 TO 12  do
  Begin
 
       INTERNA.REC1.MES_REF[Index_MRef_Cons] := TrimStr(GetString(S,ini_MesRef, 5));

       INTERNA.REC1.CONSUMO[Index_MRef_Cons] := TrimStr(GetString(S, ini_Consumo, 5));


       //Atualização posição
       ini_MesRef  := ini_MesRef + 5;
       ini_Consumo := ini_Consumo + 5;

  End;


  //DATA E LEITURA ANTERIOR

  ini_Data_Anterior  := 2062;

  ini_Leitura_Anterior := 2182;

  For Index_Historico := 1 TO 12  do
  Begin
 
    INTERNA.REC1.DT_L_ANTER[Index_Historico] := TrimStr(GetString(S,ini_Data_Anterior, 10));
    INTERNA.REC1.L_ANTERIOR[Index_Historico] := TrimStr(GetString(S,ini_Leitura_Anterior, 6));


    //Atualiza posição
    ini_Data_Anterior    := ini_Data_Anterior + 10;
    ini_Leitura_Anterior := ini_Leitura_Anterior + 6;

  End;

  
//---------- FIM - HISTORICO DE CONSUMO ----------

  BeginPage(INTERNA);
   WriteRecord(INTERNA,REC1);
  EndPage(INTERNA);

//---------- FIM - INTERNA ----------

//---------- INICIO - LIMPEZA DE MEMOS ----------


  INTERNA.REC1.MSG_INF_I[1] := '';
  INTERNA.REC1.MSG_INF_I[2] := '';

  For x_clear := 1 to 12 do
   Begin

    INTERNA.REC1.DT_L_ANTER[x_clear] := '';    
    INTERNA.REC1.L_ANTERIOR[x_clear] := '';
    INTERNA.REC1.CONSUMO[x_clear]    := '';
    INTERNA.REC1.MES_REF[x_clear]    := '';

   End;

  For x_clear := 1 to 8 do
   Begin
    
     INTERNA.REC1.DESC_SERV[x_clear] := '';
     INTERNA.REC1.VLR_SERV[x_clear]  := '';  

   End;

  For x_clear := 1 TO 6  do
   Begin

     INTERNA.REC1.DESC_OU_S[x_clear] := '';
     INTERNA.REC1.VLR_OU_S[x_clear]  := '';
    
   End;

  For x_clear := 1 TO 3  do
   Begin

     INTERNA.REC1.COBR_TERCE[x_clear] := '';
     INTERNA.REC1.VLR_COB_TE[x_clear] := '';

   End;

  For x_clear := 1 to 5 do
   Begin

     INTERNA.REC1.TARIFA_R[x_clear] := '';
     INTERNA.REC1.T_SOCIAL[x_clear] := '';

   End;

  For x_clear := 1 to 4 do
   Begin

     INTERNA.REC1.TARIFA_C[x_clear] := '';

   End;

//---------- FIM - LIMPEZA DE MEMOS ----------



END
ELSE
BEGIN


//---------- INICIO - INTERNA_DE ----------

  ClearFields(INTERNA_DE,REC1);

  INTERNA_DE.REC1.MSG_INF_I[1] := TrimStr(GetString(S,2,60));
  INTERNA_DE.REC1.MSG_INF_I[2] := TrimStr(GetString(S,62,60));

//---------- INICIO - REGIÃO SUPERIOR ----------

  INTERNA_DE.REC1.CONSUMIDOR := sNome_Consumidor  + ' - ' + TrimStr(GetString(S,173,30));
  INTERNA_DE.REC1.INQUILINO  := sNome_Inquilino;
  INTERNA_DE.REC1.COD_LIGACA := sCod_Ligacao;
  INTERNA_DE.REC1.HIDROMETRO := sNum_Hidrometro;
  INTERNA_DE.REC1.ENDERECO_1 := sEnd_Rua + ', ' + sEnd_Numero_Imovel + sEnd_Complemento; 
  INTERNA_DE.REC1.ENDERECO_2 := sEnd_Bairro;
  INTERNA_DE.REC1.ENDERECO_3 := sEnd_CEP + ' - ' + sEnd_Localidade;

  INTERNA_DE.REC1.E_RESIDE   := TrimStr(GetString(S,404,2));
  INTERNA_DE.REC1.E_COMER    := TrimStr(GetString(S,406,2));
  INTERNA_DE.REC1.E_INDUSTRI := TrimStr(GetString(S,408,2));
  INTERNA_DE.REC1.E_PUBLI    := TrimStr(GetString(S,410,2));
  INTERNA_DE.REC1.E_SOCIAIS  := TrimStr(GetString(S,412,2));
  INTERNA_DE.REC1.E_PUBLICA  := TrimStr(GetString(S,3109,2));
  INTERNA_DE.REC1.E_ENTIDADE := TrimStr(GetString(S,3111,2));

//---------- FIM - REGIÃO SUPERIOR ----------

//---------- INICIO - TABELA TARIFÁRIA ----------

  INTERNA_DE.REC1.TBO_RES    := FormatFloat(GetFloat(S,666,8),'#.###,##');
  INTERNA_DE.REC1.TBO_COM    := FormatFloat(GetFloat(S,674,8),'#.###,##');
  INTERNA_DE.REC1.TBO_SOCIAL := FormatFloat(GetFloat(S,658,8),'#.###,##');

 ini_Tarifa_Residencial := 477;

 For X := 1 TO 5  do
  Begin

     INTERNA_DE.REC1.TARIFA_R[X] := FormatFloat(GetFloat(S,ini_Tarifa_Residencial,8),'#.###,###');
 
     ini_Tarifa_Residencial := ini_Tarifa_Residencial + 8;

  End;


 ini_Tarifa_Comercial := 517;

 For X := 1 TO 4  do
  Begin

     INTERNA_DE.REC1.TARIFA_C[X] := FormatFloat(GetFloat(S,ini_Tarifa_Comercial,8),'#.###,###');
 
     ini_Tarifa_Comercial := ini_Tarifa_Comercial + 8;

  End;


 ini_Tarifa_Social := 618;

 For X := 1 TO 5  do
  Begin

     INTERNA_DE.REC1.T_SOCIAL[X] := FormatFloat(GetFloat(S,ini_Tarifa_Social,8),'#.###,###');
 
     ini_Tarifa_Social := ini_Tarifa_Social + 8;

  End;

//---------- FIM - TABELA TARIFÁRIA ----------


//---------- INICIO - INFORMAÇÕES DE LEITURA ----------

  INTERNA_DE.REC1.LL_ANTERIO := FormatFloat(GetFloat(S,600,6),'9999');
  INTERNA_DE.REC1.LL_ATUAL   := FormatFloat(GetFloat(S,606,6),'9999');

  INTERNA_DE.REC1.DT_ANTERIO := GetString(S,2043,10);
  INTERNA_DE.REC1.DT_ATUAL   := FormatDate(GetDate(S,327,6),'DD/MM/AAAA');
  INTERNA_DE.REC1.CONSUM_MES := FormatFloat(GetFloat(S,612,4),'9999');
  INTERNA_DE.REC1.DIAS_CONSU := GetString(S,616,2);

//---------- FIM - INFORMAÇÕES DE LEITURA ----------

  INTERNA_DE.REC1.MES_REFERE := GetString(S,1983,2) + '/' + GetString(S,1985,4);
  INTERNA_DE.REC1.DATA_VENC  := FormatDate(GetDate(S,1990,8),'DD/MM/AAAA');
  INTERNA_DE.REC1.VALOR_FATU := FormatFloat(GetFloat(S,549,11)/100,'9.999,99');

  INTERNA_DE.REC1.N_BANCO      := TrimStr(GetString(S,361,23));
  INTERNA_DE.REC1.NUM_BANCO    := TrimStr(GetString(S,333,8));
  INTERNA_DE.REC1.CONTA_C      := TrimStr(GetString(S,1864,15));


//---------- INICIO - VALORES DO BOLETO ----------

  INTERNA_DE.REC1.SEQUENCIAL := GetString(S,1959,12);
  INTERNA_DE.REC1.DIG        := GetString(S,800,2);

  INTERNA_DE.REC1.VL_FATUR_B := FormatFloat(GetFloat(S,1971,12),'9.999,99');

  //Débito em Conta
  If((TrimStr(GetString(S,846,11)) = '***********') and (TrimStr(GetString(S,1921,10)) <> '' )) then
  Begin
   
     INTERNA_DE.REC1.LIN_DIG    := GetString(S,1921,38);

  End
   Else
   Begin

     INTERNA_DE.REC1.LIN_DIG    := GetString(S,846,55);
     INTERNA_DE.REC1.BARCODE    := GetString(S,802,44);


     INTERNA_DE.REC1.PIX        := TrimStr(GetString(S,3113,180));   
     INTERNA_DE.REC1.TXT_PIX    := 'PAGUE COM PIX';
     INTERNA_DE.REC1.SETA       := 'ITEM1';
  
   End;

  INTERNA_DE.REC1.DT_LMT_P   := GetString(S,394,10);
  INTERNA_DE.REC1.DT_LMT_CT  := GetString(S,3098,10);
  INTERNA_DE.REC1.DATA_VENC2 := GetString(S,419,10);
  INTERNA_DE.REC1.V_FATURA_2 := FormatFloat(GetFloat(S,466,11),'9.999,99');


//---------- FIM - VALORES DO BOLETO ----------


//---------- INICIO - TABELA DESCRIÇÃO VALORES ----------

 ini_T_D_Tributos   := 904;
 Index_T_D_Tributos := 1;

 For X := 1 TO 8  do
  Begin

     //DESCRIÇÃO DE TRIBUTOS
     If(GetFloat(S,ini_T_D_Tributos + 38, 11) > 0) then 
      Begin
    
      INTERNA_DE.REC1.DESC_SERV[Index_T_D_Tributos] := TrimStr(GetString(S,ini_T_D_Tributos,38));
      INTERNA_DE.REC1.VLR_SERV[Index_T_D_Tributos]  := FormatFloat(GetFloat(S,ini_T_D_Tributos + 38, 11)/100,'9.999,99');
    
      Index_T_D_Tributos := Index_T_D_Tributos + 1;

      End;


      //Atualizando posição
      ini_T_D_Tributos  := ini_T_D_Tributos + 49;
    
  End;


 ini_Cobranca_Terceiros   := 1394;
 Index_Cobranca_Terceiros := 1;
 
 For  Y := 1 TO 3  do
  Begin

      //COBRANÇA TERCEIROS
     If(GetFloat(S,ini_Cobranca_Terceiros + 38, 11) > 0) then 
      Begin

         INTERNA_DE.REC1.COBR_TERCE[Index_Cobranca_Terceiros] := TrimStr(GetString(S,ini_Cobranca_Terceiros, 38));
         INTERNA_DE.REC1.VLR_COB_TE[Index_Cobranca_Terceiros] := FormatFloat(GetFloat(S,ini_Cobranca_Terceiros + 38, 11)/100,'9.999,99');

         Index_Cobranca_Terceiros := Index_Cobranca_Terceiros + 1;

      End;

      //Atualizando posição
      ini_Cobranca_Terceiros  := ini_Cobranca_Terceiros + 49;

  End;


 ini_OutrosServicos   := 1541;
 Index_OutrosServicos := 1;
 
 For Z := 1 TO 6  do
  Begin

     //OUTROS SERVIÇOS
     If(GetFloat(S,ini_OutrosServicos + 38, 11) > 0) then 
      Begin

        INTERNA_DE.REC1.DESC_OU_S[Index_OutrosServicos] := TrimStr(GetString(S, ini_OutrosServicos, 38));
        INTERNA_DE.REC1.VLR_OU_S[Index_OutrosServicos]  := FormatFloat(GetFloat(S,ini_OutrosServicos + 38, 11)/100,'9.999,99');

        Index_OutrosServicos := Index_OutrosServicos + 1;

      End;

      //Atualizando posição
      ini_OutrosServicos  := ini_OutrosServicos + 49;

  End;


  //MULTAS E JUROS

  INTERNA_DE.REC1.D_MULTA  := TrimStr(GetString(S,1296,38));
  INTERNA_DE.REC1.D_MULTA1 := TrimStr(GetString(S,1345,38));

  INTERNA_DE.REC1.VLR_MULTA  := GetFloat(S,1334,11)/100;
  INTERNA_DE.REC1.VLR_MULTA1 := GetFloat(S,1383,11)/100;

  
//---------- FIM - TABELA DESCRIÇÃO VALORES ----------



//---------- INICIO - HISTORICO DE CONSUMO ----------

  //CONSUMO MÉDIO
  INTERNA_DE.REC1.CONSUMO_M  := FormatFloat(GetFloat(S,310,5),'9999');

  //CONSUMO ANTERIOR

  INTERNA_DE.REC1.CONSUMO[1] := TrimStr(GetString(S,564,5));
  INTERNA_DE.REC1.CONSUMO[2] := TrimStr(GetString(S,572,5));
  INTERNA_DE.REC1.CONSUMO[3] := TrimStr(GetString(S,580,5));

  //MES REF. ANTERIOR

  INTERNA_DE.REC1.MES_REF[1] :=  TrimStr(GetString(S,1882, 5));
  INTERNA_DE.REC1.MES_REF[2] :=  TrimStr(GetString(S,1887, 5));
  INTERNA_DE.REC1.MES_REF[3] :=  TrimStr(GetString(S,1892, 5));

  ini_MesRef := 2299;

  ini_Consumo := 2254;

  For Index_MRef_Cons := 4 TO 12  do
  Begin
 
       INTERNA_DE.REC1.MES_REF[Index_MRef_Cons] := TrimStr(GetString(S,ini_MesRef, 5));

       INTERNA_DE.REC1.CONSUMO[Index_MRef_Cons] := TrimStr(GetString(S, ini_Consumo, 5));


       //Atualização posição
       ini_MesRef  := ini_MesRef + 5;
       ini_Consumo := ini_Consumo + 5;

  End;


  //DATA E LEITURA ANTERIOR

  ini_Data_Anterior  := 2062;

  ini_Leitura_Anterior := 2182;

  For Index_Historico := 1 TO 12  do
  Begin
 
    INTERNA_DE.REC1.DT_L_ANTER[Index_Historico] := TrimStr(GetString(S,ini_Data_Anterior, 10));
    INTERNA_DE.REC1.L_ANTERIOR[Index_Historico] := TrimStr(GetString(S,ini_Leitura_Anterior, 6));


    //Atualiza posição
    ini_Data_Anterior    := ini_Data_Anterior + 10;
    ini_Leitura_Anterior := ini_Leitura_Anterior + 6;

  End;

  
//---------- FIM - HISTORICO DE CONSUMO ----------

  BeginPage(INTERNA_DE);
   WriteRecord(INTERNA_DE,REC1);
  EndPage(INTERNA_DE);

//---------- FIM - INTERNA_DE ----------

//---------- INICIO - LIMPEZA DE MEMOS ----------

  INTERNA_DE.REC1.MSG_INF_I[1] := '';
  INTERNA_DE.REC1.MSG_INF_I[2] := '';

  For x_clear := 1 to 12 do
   Begin

    INTERNA_DE.REC1.DT_L_ANTER[x_clear] := '';    
    INTERNA_DE.REC1.L_ANTERIOR[x_clear] := '';
    INTERNA_DE.REC1.CONSUMO[x_clear]    := '';
    INTERNA_DE.REC1.MES_REF[x_clear]    := '';

   End;

  For x_clear := 1 to 8 do
   Begin
    
     INTERNA_DE.REC1.DESC_SERV[x_clear] := '';
     INTERNA_DE.REC1.VLR_SERV[x_clear]  := '';  

   End;

  For x_clear := 1 TO 6  do
   Begin

     INTERNA_DE.REC1.DESC_OU_S[x_clear] := '';
     INTERNA_DE.REC1.VLR_OU_S[x_clear]  := '';
    
   End;

  For x_clear := 1 TO 3  do
   Begin

     INTERNA_DE.REC1.COBR_TERCE[x_clear] := '';
     INTERNA_DE.REC1.VLR_COB_TE[x_clear] := '';

   End;

  For x_clear := 1 to 5 do
   Begin

     INTERNA_DE.REC1.TARIFA_R[x_clear] := '';
     INTERNA_DE.REC1.T_SOCIAL[x_clear] := '';

   End;

  For x_clear := 1 to 4 do
   Begin

     INTERNA_DE.REC1.TARIFA_C[x_clear] := '';

   End;

//---------- FIM - LIMPEZA DE MEMOS ----------

END;

//---------- INICIO - EXTERNA ----------

  ClearFields(EXTERNA,REC1);

  EXTERNA.REC1.E_RESIDE   := TrimStr(GetString(S,404,2));
  EXTERNA.REC1.E_COMER    := TrimStr(GetString(S,406,2));
  EXTERNA.REC1.E_INDUSTRI := TrimStr(GetString(S,408,2));
  EXTERNA.REC1.E_PUBLI    := TrimStr(GetString(S,410,2));
  EXTERNA.REC1.E_SOCIAIS  := TrimStr(GetString(S,412,2));
  EXTERNA.REC1.E_PUBLICA  := TrimStr(GetString(S,3109,2));
  EXTERNA.REC1.E_ENTIDADE := TrimStr(GetString(S,3111,2));


  EXTERNA.REC1.CONSUMIDOR := sNome_Consumidor;
  EXTERNA.REC1.INQUILINO  := sNome_Inquilino;
  EXTERNA.REC1.COD_LIGACA := sCod_Ligacao;
  EXTERNA.REC1.HIDROMETRO := sNum_Hidrometro;
  EXTERNA.REC1.ENDERECO_1 := sEnd_Rua + ', ' + sEnd_Numero_Imovel + sEnd_Complemento; 
  EXTERNA.REC1.ENDERECO_2 := sEnd_Bairro;
  EXTERNA.REC1.ENDERECO_3 := sEnd_CEP + ' - ' + sEnd_Localidade;
  EXTERNA.REC1.ORDE_ATEND := sOrder_Atendimento;
  EXTERNA.REC1.ROTA       := sCod_Rota;

//---------- INICIO - TABELA QUALIDADE DE ÁGUA ----------

ini_Tabela  := 2466;
size_Tabela := 54;

For Index_Tabela := 1 TO 8  do
Begin

  EXTERNA.REC1.PARAMETRO[Index_Tabela]  := TrimStr(GetString(S,ini_Tabela, 30));
  EXTERNA.REC1.VL_MX_PERM[Index_Tabela] := TrimStr(GetString(S,ini_Tabela + 30, 16));
  EXTERNA.REC1.QNTD_ANALI[Index_Tabela] := TrimStr(GetString(S,ini_Tabela + 46, 3));
  EXTERNA.REC1.RESULT_M[Index_Tabela]   := TrimStr(GetString(S,ini_Tabela + 49, 5));

  ini_Tabela := ini_Tabela + size_Tabela;

End;

//---------- FIM - TABELA QUALIDADE DE ÁGUA ----------


//---------- INICIO - MSG INFORMATIVA ----------

  EXTERNA.REC1.RESULT_A := TrimStr(GetString(S,2394,72));

  For  Index := 0 to 10   do
   Begin

      EXTERNA.REC1.DESC_PARAM[Index + 1] := MultLineItem(Ls_Header, Index);

   End;


  For  Index := 0 to 11   do
   Begin

      EXTERNA.REC1.IMPO_SABER[Index + 1] := MultLineItem(Ls_Header, Index + 11);

   End;


//---------- FIM - MSG INFORMATIVA ----------


  BeginPage(EXTERNA);
   WriteRecord(EXTERNA,REC1);
  EndPage(EXTERNA);

//---------- FIM - EXTERNA ----------

 //ORDENAÇÃO PELA ORDEM DE ATENDIMENTO
 //Markup(sOrder_Atendimento);


//---------- INICIO - LIMPEZA DE MEMOS ----------

//TABELA DE ANALISE DE QUALIDADE DE ÁGUA

For Index_Clear := 1 TO 8  do
Begin

   EXTERNA.REC1.PARAMETRO[Index_Clear]  := '';
   EXTERNA.REC1.VL_MX_PERM[Index_Clear] := '';
   EXTERNA.REC1.QNTD_ANALI[Index_Clear] := '';
   EXTERNA.REC1.RESULT_M[Index_Clear]   := '';

End;

//MENSAGEM DE SIGNIFICADO DA TABELA QUALIDADE DE ÁGUA

For Index_Clear := 1 TO 11  do
Begin
  
    EXTERNA.REC1.DESC_PARAM[Index_Clear] := '';

End;


//MENSAGEM INFORMATIVA NA PARTE INFERIOR DA PÁGINA EXTERNA

For Index_Clear := 1 TO 12  do
Begin

    EXTERNA.REC1.IMPO_SABER[Index_Clear] := '';

End;

//---------- FIM - LIMPEZA DE MEMOS ----------


End;

//---------- FIM - GRAVAÇÃO ----------


//Convert(1,false,false,true,0,false);


//------------ INICIO -  CAPA DE LOTE ------

 // 2 VIAS
 ClearFields(BRANCO,REC1);

 BRANCO.REC1.ARQUIVO := RetornaNomeArqEntrada(0);
 BRANCO.REC1.QNTD    := FormatNumeric(nCount,'00000');

 BeginPage(BRANCO);
  WriteRecord(BRANCO,REC1);
 EndPage(BRANCO);

 ClearFields(BRANCO,REC1);

 BRANCO.REC1.ARQUIVO := RetornaNomeArqEntrada(0);
 BRANCO.REC1.QNTD    := FormatNumeric(nCount,'00000');

 BeginPage(BRANCO);
  WriteRecord(BRANCO,REC1);
 EndPage(BRANCO);

// ------------ FIM  - CAPA LOTE --------













