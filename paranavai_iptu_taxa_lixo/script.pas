{
   PROJETO: PARANAVAI -- IPTU + Coleta de lixo --- A3
   DATA: 18/10/2019
   DESENVOLVEDOR: VINICIUS VERAS
   SCRIPT DE IMPORTAÇÃO
}

  // -----  Convenção de palavras  -------
  //1 - Linhas do tipo n = linhas n
  //    Ex: linha do tipo 1 = linha 1 


// Neste projeto A3 haverá 2 cobranças distintas, IPTU (lado interno esquerdo) e TXCL (lado interno direito), utilizando 3 arquivos
// Caso um imóvel esteja no arquivo de TXCL e  IPTU, será gerado em A3 com as 2 taxas juntas, caso só tenha IPTU, será gerado um A4
// TXCL só aparece em A3 ou seja, não existirá A4 com apenas TXCL 


// ----------------------- OBSERVAÇÕES -----------------------------

// - Foi necessario unificar 3 arquivos, pois o cliente me encaminhou 3 arquivos para
//   a geração das guias de IPTU e Taxa de Lixo, em uma gambiarra que nunca tinha visto antes ... Fazer oq ?? rs

// - Então, coloquei delimitadores nos 2 últimos arquivos, assim saberei onde eles começam e terminam.
// - Sabendo a posição inicial poderei utilizar o mesmo layout que foi enviado pelo cliente, apenas somando a posiçao do layout com a posicão final dos
//   arquivos anteriores.

// A chave para o join foi o código do imóvel, na posicao 9 com 9 bytes

// --- Arquivo 1 -- IPTU_01 
// Não tem delimitador 

// --- Arquivo 2 -- IPTU_02 --- 
// INFORMAÇOES COMPLEMENTARES PARA O IPTU_01 E TAXA DE LIXO, POIS É -.- O ARQUIVO CHAMADO DE IPTU_02 TEM INFORMAÇOES PARA O TXCL, LAMENTÁVEL...

// delimitador inicio = _$@#


// ---- Exemplo --
//  _$@#.........(dados)...........


// --- Arquivo 3 -- COLETA DE LIXO 
// INFORMAÇOES DO TXCL E COMPLEMENTARES PARA O IPTU_01, POIS É -.- ACIMA TINHA AVISADO QUE ERA UMA GAMBIARRA SÓ ...RS

// delimitador inicio = !!!!

//----- Exemplo --
//  !!!!............(dados)...........



// ---- Globais  ------------

LParcelas      := '';
LParcelas_TXCL := '';
Seq            := 1;

//Variavel para erros
debug := '';

//-------------------



//DESCONSIDERAR HEADER
ReadLn(S);

//PONTO DE PARTIDA
While ( ReadLn(S) <> EOF ) AND ( TrimStr(S) <> '' )  do
Begin



//--- Descobrindo a posicao dos delimitadores ...

ini_Arq_2 := 0; 
ini_Arq_3 := 0;


//---  Arquivo IPTU_02

  IF PosStr('_$@#', S) <> 0 Then
    Begin 

       ini_Arq_2 := PosStr('_$@#', S) + 4;

    End
    Else
       Abort;


//--- Arquivo COLETA DE LIXO

  IF PosStr('!!!!', S) <> 0 Then
    Begin 

       ini_Arq_3 := PosStr('!!!!', S) + 4;

    End
    Else
       Abort;

//------------- FIM ----------------


//Inc 
seq := seq + 1;


//--- INSERINDO TODAS AS PARCELAS EM UM LIST PARA FACILITAR

//--- IPTU ---------

      ps_ini     := 1870;
      size_parc  := 462; 
   
      FOR X := 0 To 2 Do
       BEGIN
         LPARCELAS := MultLineAdd(LPARCELAS, GetString(S,ps_ini,size_parc));
         ps_ini := ps_ini + size_parc;
       END;

//----- FIM IPTU --------------

//------- TAXA DE COLETA DE LIXO ---------------

      ps_ini_TXCL     := 1408 + ini_Arq_3;
      size_parc_TXCL  := 462; 
   
      FOR X := 0 To 1 Do
       BEGIN
         LPARCELAS_TXCL := MultLineAdd(LPARCELAS_TXCL, GetString(S,ps_ini_TXCL,size_parc));
         ps_ini_TXCL := ps_ini_TXCL + size_parc;
       END;

//---------------- FIM ---------------------


//--- FIM -------



// ---- INICIO GRAVAÇÃO ------------------------

   ClearFields(INTERNA,REC1);   



// ---------------------------------- IPTU - INTERNA LADO ESQUERDA ----------------------------------


//----- MENSAGEM DIVIDA ATIVA ------


   IF(GetFloat(S,(ini_Arq_2),28)/100 = 1) then
    Begin
      INTERNA.REC1.M_DBT_IPTU := 'ITEM1';
      INTERNA.REC1.M_DBT_TXCL := 'ITEM1';
    End 
     ELSE
      BEGIN
         INTERNA.REC1.M_DBT_IPTU := 'ITEM2';
         INTERNA.REC1.M_DBT_TXCL := 'ITEM2';
      END;
  
// ------- FIM MENSAGEM DIVIDA ATIVA ----------------------


// -------------------------------  DADOS CADASTRAIS  -----------------------

      INTERNA.REC1.INSCR       := FormatFloat(GetFloat(S,9,9),'9999');
      INTERNA.REC1.ID_CONTRI   := FormatFloat(GetFloat(S,18,9),'9999');
      INTERNA.REC1.INSC_IMOB   := TrimStr(GetString(S,27,25));
      INTERNA.REC1.PROP        := TrimStr(GetString(S,52,60));

//---------------------------------- FIM DADOS CADASTRAIS ----------------------------
 
//-------------------------------- ENDEREÇO DO IMÓVEL ----------------------------------------

      INTERNA.REC1.END         := TrimStr(GetString(S,386,100));
      INTERNA.REC1.QUADRA      := TrimStr(GetString(S,664,12));
      INTERNA.REC1.LOTE        := TrimStr(GetString(S,676,12));

    
      cpl := '';

      //Complemtento
      if(TrimStr(GetString(S,486,50)) <> '') then
       begin
         cpl := cpl + TrimStr(GetString(S,486,50));
       end;

    //bloco
    if(TrimStr(GetString(S,650,6)) <> '') then
       begin
         cpl := cpl + ' bloco - ' + TrimStr(GetString(S,650,6));
       end;


    //apto
    if(TrimStr(GetString(S,656,8)) <> '') then
       begin
         cpl := cpl + ' apto - ' + TrimStr(GetString(S,656,8));
       end;

      INTERNA.REC1.BAIRRO      := TrimStr(GetString(S,536,50));
      INTERNA.REC1.END_COMPL   := cpl;

      INTERNA.REC1.CEP         := GetString(S,586,5) + '-' + GetString(S,591,3);


// -------------------------------------- FIM ENDEREÇO DO IMÓVEL  -------------------------

   
//  --------------------- TABELA - TRIBUTOS LANÇADOS  --------------------------

       ini_Tributos  := 1478;
       valor_taxa    := 0.0;
       tam_tributos  := 49;
       total_imposto := 0.0;
       isTaxa        := false;
       

        FOR X := 1 TO 5 DO 
         BEGIN 

           IF(GetFloat(S,(ini_Tributos + 25),12) > 0) then
            BEGIN
                 INTERNA.REC1.TRIBUTOS[X]   := trimStr(GetString(S,ini_Tributos,25)) + ' (R$):';
                 INTERNA.REC1.V_TRIBUTOS[X] := FormatFloat(GetFloat(S,(ini_Tributos + 25),12)/100,'9.999,99');
            END;

           //Vá para o próximo tributo
           ini_Tributos := ini_Tributos + tam_tributos;
 
         END;



      INTERNA.REC1.T_IMPOSTO   := GetFloat(S,1418,12)/100;
      INTERNA.REC1.DTVENC_PRI  := GetString(S,1410,2) + '/' + GetString(S,1412,2) + '/' + GetString(S,1414,4);


// -------------------------   FIM TABELA - TRIBUTOS LANÇADOS ------------------------------

      //ARQUIVO 1
      INTERNA.REC1.AREA_T      := FormatFloat(GetFloat(S,1138,28)/100,'9.999,99');
      INTERNA.REC1.AREA_C      := FormatFloat(GetFloat(S,1168,28)/100,'9.999,99');
      INTERNA.REC1.TESTADA_P   := FormatFloat(GetFloat(S,1198,28)/100,'9.999,99');
      INTERNA.REC1.VL_VEN_E    := FormatFloat(GetFloat(S,1228,28)/100,'9.999,99');
      INTERNA.REC1.VL_VN_T     := FormatFloat(GetFloat(S,1258,28)/100,'9.999,99');
      INTERNA.REC1.ALIQUOTA    := FormatFloat(GetFloat(S,1288,28)/100,'9.999,99');
      INTERNA.REC1.FRACAO_IDE  := FormatFloat(GetFloat(S,1378,28)/100,'9.999,99');
    

       //-- ARQUIVO 2
       INTERNA.REC1.AREA_T_C    := FormatFloat(GetFloat(S, (ini_Arq_2 + 60),28)/100,'9.999,99');
       INTERNA.REC1.VL_V_T      := FormatFloat(GetFloat(S,(ini_Arq_2 + 120),28)/100,'9.999,99');




// ------------------- TABELA DADOS DO TERRENO/IMÓVEL -------------------

//-- 3
   INTERNA.REC1.TB_T_I_1 := TrimStr(GetString(S,(ini_Arq_2 + 90),30));

//-- 1
   INTERNA.REC1.TB_T_I_2 := TrimStr(GetString(S,808,30));

// -- 1
   INTERNA.REC1.TB_T_I_3 := TrimStr(GetString(S,1048,30));

// -- 1
   INTERNA.REC1.TB_T_I_4 := TrimStr(GetString(S,748,30));

// -- 1
   INTERNA.REC1.TB_T_I_5 := TrimStr(GetString(S,1348,30));

// -- 1
   INTERNA.REC1.TB_T_I_6 := TrimStr(GetString(S,988,30));

// -- 1
   INTERNA.REC1.TB_T_I_7 := TrimStr(GetString(S,718,30));

// -- 1
   INTERNA.REC1.TB_T_I_8 := TrimStr(GetString(S,898,30));

// -- 1
   INTERNA.REC1.TB_T_I_9 := TrimStr(GetString(S,1018,30));

// -- 1
   INTERNA.REC1.TB_T_I_10 := TrimStr(GetString(S,778,30));

// --1
   INTERNA.REC1.TB_T_I_11 := TrimStr(GetString(S,838,30));

// -- 1
   INTERNA.REC1.TB_T_I_12 := TrimStr(GetString(S,1108,30));


// -- 3
   INTERNA.REC1.TB_T_I_13 := TrimStr(GetString(S,(ini_Arq_2 + 30),30));

// -- 1
   INTERNA.REC1.TB_T_I_14 := TrimStr(GetString(S,868,30));

// -- 3
   INTERNA.REC1.TB_T_I_15 := TrimStr(GetString(S,(ini_Arq_2 + 150 + 60),30));

// -- 1
   INTERNA.REC1.TB_T_I_16 := TrimStr(GetString(S,1318,30));

// -- 1
   INTERNA.REC1.TB_T_I_17 := TrimStr(GetString(S,928,30));

// -- 3
   INTERNA.REC1.TB_T_I_18 := TrimStr(GetString(S,(ini_Arq_2 + 150 + 90),30));

// -- 3
   INTERNA.REC1.TB_T_I_19 := TrimStr(GetString(S,(ini_Arq_2 + 150),30));

// -- 1
   INTERNA.REC1.TB_T_I_20 := TrimStr(GetString(S,958,30));

// -- 3
   INTERNA.REC1.TB_T_I_21 := TrimStr(GetString(S,(ini_Arq_2 + 150 + 120),30));

// -- 3
   INTERNA.REC1.TB_T_I_22 := TrimStr(GetString(S,(ini_Arq_2 + 150 + 30),30));

// -- 1
   INTERNA.REC1.TB_T_I_23 := TrimStr(GetString(S,1078,30));

// FIXO POR ENQUANTO
   INTERNA.REC1.TB_T_I_24 := 'Verificar na Prefeitura';





// -------------------------------- PARCELAS -----------------------------------------------

      //************************************************  1  **************************************

      INTERNA.REC1.CODBAR1 := GetString(MultLineItem(LPARCELAS,0),23,11) + GetString(MultLineItem(LPARCELAS,0),35,11) +
                                 GetString(MultLineItem(LPARCELAS,0),47,11) + GetString(MultLineItem(LPARCELAS,0),59,11);

      INTERNA.REC1.LINDIG1 := GetString(MultLineItem(LPARCELAS,0),23,11) + '-' + GetString(MultLineItem(LPARCELAS,0),34,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,0),35,11) + '-' + GetString(MultLineItem(LPARCELAS,0),46,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,0),47,11) + '-' + GetString(MultLineItem(LPARCELAS,0),58,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,0),59,11) + '-' + GetString(MultLineItem(LPARCELAS,0),70,1);

      INTERNA.REC1.CEDENTE1 := GetString(MultLineItem(LPARCELAS,0),39,4);

      INTERNA.REC1.NUMGUIA1 := GetString(MultLineItem(LPARCELAS,0),52,6) + GetString(MultLineItem(LPARCELAS,0),59,3);

                                 
      INTERNA.REC1.VLRGUIA1 := FormatFloat(GetFloat(MultLineItem(LPARCELAS,0),11,12)/100,'9.999,99');
 

      INTERNA.REC1.DTVENC1 := GetString(MultLineItem(LPARCELAS,0),3,2) + '/' + GetString(MultLineItem(LPARCELAS,0),5,2) + '/' +
                                 GetString(MultLineItem(LPARCELAS,0),7,4); 
      
      //*************************************** FIM 1 ************************************************
 

      //************************************************  2  **************************************

       INTERNA.REC1.NUMPARC2 := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,1),1,2),'00');

       INTERNA.REC1.CODBAR2  := GetString(MultLineItem(LPARCELAS,1),23,11) + GetString(MultLineItem(LPARCELAS,1),35,11) +
                                 GetString(MultLineItem(LPARCELAS,1),47,11) + GetString(MultLineItem(LPARCELAS,1),59,11);

       INTERNA.REC1.CEDENTE2 := GetString(MultLineItem(LPARCELAS,1),39,4);

       INTERNA.REC1.LINDIG2  := GetString(MultLineItem(LPARCELAS,1),23,11) + '-' + GetString(MultLineItem(LPARCELAS,1),34,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,1),35,11) + '-' + GetString(MultLineItem(LPARCELAS,1),46,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,1),47,11) + '-' + GetString(MultLineItem(LPARCELAS,1),58,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,1),59,11) + '-' + GetString(MultLineItem(LPARCELAS,1),70,1);

       INTERNA.REC1.NUMGUIA2 := GetString(MultLineItem(LPARCELAS,1),52,6) + GetString(MultLineItem(LPARCELAS,1),59,3);

                                 
       INTERNA.REC1.VLRGUIA2 := FormatFloat(GetFloat(MultLineItem(LPARCELAS,1),11,12)/100,'9.999,99');
 

       INTERNA.REC1.DTVENC2  := GetString(MultLineItem(LPARCELAS,1),3,2) + '/' + GetString(MultLineItem(LPARCELAS,1),5,2) + '/' +
                                 GetString(MultLineItem(LPARCELAS,1),7,4); 

       //*************************************** FIM 2 ************************************************


       //******************************************** 3 **********************************************

       INTERNA.REC1.NUMPARC3 := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,2),1,2),'00');

       INTERNA.REC1.CODBAR3  := GetString(MultLineItem(LPARCELAS,2),23,11) + GetString(MultLineItem(LPARCELAS,2),35,11) +
                                 GetString(MultLineItem(LPARCELAS,2),47,11) + GetString(MultLineItem(LPARCELAS,2),59,11);

       INTERNA.REC1.LINDIG3  := GetString(MultLineItem(LPARCELAS,2),23,11) + '-' + GetString(MultLineItem(LPARCELAS,2),34,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,2),35,11) + '-' + GetString(MultLineItem(LPARCELAS,2),46,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,2),47,11) + '-' + GetString(MultLineItem(LPARCELAS,2),58,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS,2),59,11) + '-' + GetString(MultLineItem(LPARCELAS,2),70,1);

       INTERNA.REC1.CEDENTE3 := GetString(MultLineItem(LPARCELAS,2),39,4);

       INTERNA.REC1.NUMGUIA3 := GetString(MultLineItem(LPARCELAS,2),52,6) + GetString(MultLineItem(LPARCELAS,2),59,3);

                                 
       INTERNA.REC1.VLRGUIA3 := FormatFloat(GetFloat(MultLineItem(LPARCELAS,2),11,12)/100,'9.999,99');
 

       INTERNA.REC1.DTVENC3  := GetString(MultLineItem(LPARCELAS,2),3,2) + '/' + GetString(MultLineItem(LPARCELAS,2),5,2) + '/' +
                                 GetString(MultLineItem(LPARCELAS,2),7,4); 

       //********************************************* Fim 3 *******************************************************

      
// --------------------------------  FIM PARCELAS -----------------------------------------------


//----------------------------------- FIM IPTU - INTERNA LADO ESQUERDO -------------------------


//------------------------ TAXA DE COLETA DE LIXO - INTERNA LADO DIREITO ------------------------------


// -------------------------------- PARCELAS -----------------------------------------------

      //************************************************  1  **************************************

      INTERNA.REC1.CODBAR4 := GetString(MultLineItem(LPARCELAS_TXCL,1 ),23,11) + GetString(MultLineItem(LPARCELAS_TXCL,1 ),35,11) +
                                 GetString(MultLineItem(LPARCELAS_TXCL,1 ),47,11) + GetString(MultLineItem(LPARCELAS_TXCL,1 ),59,11);

      INTERNA.REC1.LINDIG4 := GetString(MultLineItem(LPARCELAS_TXCL,1 ),23,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,1 ),34,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,1 ),35,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,1 ),46,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,1 ),47,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,1 ),58,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,1 ),59,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,1 ),70,1);

      INTERNA.REC1.CEDENTE4 := GetString(MultLineItem(LPARCELAS_TXCL,1),39,4);

      INTERNA.REC1.NUMGUIA4 := GetString(MultLineItem(LPARCELAS_TXCL,1 ),52,6) + GetString(MultLineItem(LPARCELAS_TXCL,1 ),59,3);

                                 
      INTERNA.REC1.VLRGUIA4 := FormatFloat(GetFloat(MultLineItem(LPARCELAS_TXCL,1 ),11,12)/100,'9.999,99');
 

      INTERNA.REC1.DTVENC4 := GetString(MultLineItem(LPARCELAS_TXCL,1 ),3,2) + '/' + GetString(MultLineItem(LPARCELAS_TXCL,1 ),5,2) + '/' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,1 ),7,4); 
      
      //*************************************** FIM 1 ************************************************
 

      //************************************************  2  **************************************

       INTERNA.REC1.NUMPARC5 := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS_TXCL,0 ),1,2),'00');

       INTERNA.REC1.CODBAR5  := GetString(MultLineItem(LPARCELAS_TXCL,0 ),23,11) + GetString(MultLineItem(LPARCELAS_TXCL,0 ),35,11) +
                                 GetString(MultLineItem(LPARCELAS_TXCL,0 ),47,11) + GetString(MultLineItem(LPARCELAS_TXCL,0 ),59,11);

       INTERNA.REC1.LINDIG5  := GetString(MultLineItem(LPARCELAS_TXCL,0 ),23,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,0 ),34,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,0 ),35,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,0 ),46,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,0 ),47,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,0 ),58,1) + ' ' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,0 ),59,11) + '-' + GetString(MultLineItem(LPARCELAS_TXCL,0 ),70,1);

       INTERNA.REC1.CEDENTE5 := GetString(MultLineItem(LPARCELAS_TXCL,0),39,4);

       INTERNA.REC1.NUMGUIA5 := GetString(MultLineItem(LPARCELAS_TXCL,0 ),52,6) + GetString(MultLineItem(LPARCELAS_TXCL,0 ),59,3);

                                 
       INTERNA.REC1.VLRGUIA5 := FormatFloat(GetFloat(MultLineItem(LPARCELAS_TXCL,0 ),11,12)/100,'9.999,99');
 

       INTERNA.REC1.DTVENC5  := GetString(MultLineItem(LPARCELAS_TXCL,0 ),3,2) + '/' + GetString(MultLineItem(LPARCELAS_TXCL,0 ),5,2) + '/' +
                                 GetString(MultLineItem(LPARCELAS_TXCL,0 ),7,4); 

       //*************************************** FIM 2 ************************************************


     
// ------------- TABELA DADOS DO TERRENO/IMÓVEL ------
// APENAS O CAMPO OCUPACAO, POIS O RESTANTE FOI UTILIZADO DO IPTU

// -- 1
   INTERNA.REC1.TB_T_I_25 := TrimStr(GetString(S,688,30));

//------ FIM -----


//  --------------------- TABELA - TRIBUTOS LANÇADOS  --------------------------

       ini_Tributos  := 1478 + ini_Arq_3;
       valor_taxa    := 0.0;
       tam_tributos  := 49;
       total_imposto := 0.0;
       isTaxa        := false;
       

        FOR X := 1 TO 5 DO 
         BEGIN 

           IF(GetFloat(S,(ini_Tributos + 25),12) > 0) then
            BEGIN
                 INTERNA.REC1.TRIBUTOS1[X]   := trimStr(GetString(S,ini_Tributos,25)) + ' (R$):';
                 INTERNA.REC1.VL_TRIB_2[X]   := FormatFloat(GetFloat(S,(ini_Tributos + 25),12)/100,'9.999,99');
            END;

           //Vá para o próximo tributo
           ini_Tributos := ini_Tributos + tam_tributos;
 
         END;


      INTERNA.REC1.T_IMPOSTO1   := GetFloat(S,(1418 + ini_Arq_3),12)/100;
      INTERNA.REC1.DT_VC_P_TX   := GetString(S,(1410 + ini_Arq_3),2) + '/' + GetString(S,(1412 + ini_Arq_3),2) + '/' + GetString(S,(1414 + ini_Arq_3),4);


// -------------------------   FIM TABELA - TRIBUTOS LANÇADOS ------------------------------


// -------------------------------  DADOS CADASTRAIS  -----------------------

      INTERNA.REC1.INSCR1       := FormatFloat(GetFloat(S,(9 + ini_Arq_3),9),'9999');
      INTERNA.REC1.ID_CONTRI1   := FormatFloat(GetFloat(S,(18 + ini_Arq_3),9),'9999');
      INTERNA.REC1.INSC_IMOB1   := TrimStr(GetString(S,(27 + ini_Arq_3),25));
      INTERNA.REC1.PROP1        := TrimStr(GetString(S,(52 + ini_Arq_3),60));

//---------------------------------- FIM DADOS CADASTRAIS ----------------------------


//-------------------------------- ENDEREÇO DO IMÓVEL ----------------------------------------

      INTERNA.REC1.END1         := TrimStr(GetString(S,(386 + ini_Arq_3),100));
      INTERNA.REC1.QUADRA1      := TrimStr(GetString(S,(664 + ini_Arq_3),12));
      INTERNA.REC1.LOTE1        := TrimStr(GetString(S,(676 + ini_Arq_3),12));

    
      cpl1 := '';

      //Complemtento
      if(TrimStr(GetString(S,(486 + ini_Arq_3),50)) <> '') then
       begin
         cpl1 := cpl1 + TrimStr(GetString(S,(486 + ini_Arq_3),50));
       end;

    //bloco
    if(TrimStr(GetString(S,(650 + ini_Arq_3),6)) <> '') then
       begin
         cpl1 := cpl1 + ' bloco - ' + TrimStr(GetString(S,(650 + ini_Arq_3),6));
       end;


    //apto
    if(TrimStr(GetString(S,(656 + ini_Arq_3),8)) <> '') then
       begin
         cpl1 := cpl1 + ' apto - ' + TrimStr(GetString(S,(656 + ini_Arq_3),8));
       end;

      INTERNA.REC1.BAIRRO1      := TrimStr(GetString(S,(536 + ini_Arq_3),50));
      INTERNA.REC1.END_COMPL1   := cpl1;

      INTERNA.REC1.CEP1         := GetString(S,(586 + ini_Arq_3),5) + '-' + GetString(S,(591 + ini_Arq_3),3);

//------------------------- FIM ENDEREÇO IMÓVEL TXCL --------------------------------------


       BeginPage(INTERNA);
         WriteRecord(INTERNA,REC1);
       EndPage(INTERNA);

//----------------------- FIM GRAVAÇÃO INTERNA -----------------------------------


//---------- Limpando Variaveis Interna -----------

 LParcelas       := MultLineClear(LParcelas);
 LParcelas_TXCL  := MultLineClear(LParcelas_TXCL);

 FOR X := 1 TO 5 DO 
  BEGIN 
    INTERNA.REC1.TRIBUTOS[X]   := '';
    INTERNA.REC1.V_TRIBUTOS[X] := '';
    INTERNA.REC1.TRIBUTOS1[X]  := '';
    INTERNA.REC1.VL_TRIB_2[X]  := '';

  END;

//--------------------- FIM DE LIMPEZA ------------------


// -------------  GRAVAÇAO EXTERNA ---------------------


      ClearFields(EXTERNA,REC1);
      
     
      EXTERNA.REC1.INSCR       := FormatFloat(GetFloat(S,9,9),'9999');
      EXTERNA.REC1.ID_CONTRI   := FormatFloat(GetFloat(S,18,9),'9999');
      EXTERNA.REC1.INSC_IMOB   := TrimStr(GetString(S,27,25));
      EXTERNA.REC1.PROP        := TrimStr(GetString(S,52,60));


// -- 1
   EXTERNA.REC1.TB_T_I_25 := TrimStr(GetString(S,688,30));

//---------------------- ENDEREÇO DE ENTREGA -------------------------

  
 indexMemoEndEntrega := 1;
 pulaLinha := 0;

 //Logradouro
 EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] :=  TrimStr(GetString(S,112,100));
 pulaLinha := 1;


//-- Atualizando o indice do memo caso necessario 
IF(pulaLinha = 1) then
Begin
     pulaLinha := 0;
     indexMemoEndEntrega := indexMemoEndEntrega + 1;
End;


 cpl_entrega := '';

 //Complemento
 IF(TrimStr(GetString(S,212,50)) <> '') Then
  Begin

     cpl_entrega := cpl_entrega + TrimStr(GetString(S,212,50));
     EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] :=  cpl_entrega;
     pulaLinha := 1;
  End;


 //Bloco
 IF(TrimStr(GetString(S,262,6)) <> '') then
   Begin

      cpl_entrega := cpl_entrega + ' - BL: ' +  TrimStr(GetString(S,262,6));
      EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] := cpl_entrega;
      pulaLinha := 1;
   End;

 //Apartamento
 IF(TrimStr(GetString(S,268,8)) <> '') then
   Begin

      cpl_entrega := cpl_entrega + ', APTO: ' +  TrimStr(GetString(S,268,8));
      EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] := cpl_entrega;
      pulaLinha := 1;
   End;


//-- Atualizando o indice do memo caso necessario 
IF(pulaLinha = 1) then
Begin
     pulaLinha := 0;
     indexMemoEndEntrega := indexMemoEndEntrega + 1;
End;


 //Bairro, caso seja diferente do Complemento
 IF((TrimStr(GetString(S,276,50)) <> '') and (UpperStr(TrimStr(GetString(S,276,50))) <> UpperStr(TrimStr(GetString(S,212,50))))) then
   Begin
      EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] := TrimStr(GetString(S,276,50));
      pulaLinha := 1;
   End;

//-- Atualizando o indice do memo caso necessario 
IF(pulaLinha = 1) then
Begin
     pulaLinha := 0;
     indexMemoEndEntrega := indexMemoEndEntrega + 1;
End;

  //Cep, Cidade e UF
  EXTERNA.REC1.END_ENTREG[indexMemoEndEntrega] := TrimStr(GetString(S,378,5)) + '-' + TrimStr(GetString(S,383,3)) + ' - ' +
                                                      TrimStr(GetString(S,326,50)) + '/' + TrimStr(GetString(S,376,2));

//------------------------- FIM ENDEREÇO ENTREGA ----------------


//---------------------------- Endereço Imóvel -------------------



 //Logradouro
 EXTERNA.REC1.END_IMOV :=  TrimStr(GetString(S,386,100));


 indexMemoEndImovel := 1;
 pulaLinha := 0;


 cpl_imov := '';

 //Complemento
 IF(TrimStr(GetString(S,486,50)) <> '') Then
  Begin

     cpl_imov := cpl_imov + TrimStr(GetString(S,486,50));

     EXTERNA.REC1.END_I_COMP[indexMemoEndImovel] :=  cpl_imov;
     pulaLinha := 1;
  End;


 //Bloco
 IF(TrimStr(GetString(S,650,6)) <> '') then
   Begin
      
      cpl_imov := cpl_imov + ' - BL: ' +  TrimStr(GetString(S,650,6));

      EXTERNA.REC1.END_I_COMP[indexMemoEndImovel] := cpl_imov;
      pulaLinha := 1;
   End;

 //Apartamento
 IF(TrimStr(GetString(S,656,8)) <> '') then
   Begin

      cpl_imov := cpl_imov + ', APTO: ' +  TrimStr(GetString(S,656,8));
      EXTERNA.REC1.END_I_COMP[indexMemoEndImovel] := cpl_imov;
      pulaLinha := 1;
   End;


//-- Atualizando o indice do memo caso necessario 
IF(pulaLinha = 1) then
Begin
     pulaLinha := 0;
     indexMemoEndImovel := indexMemoEndImovel + 1;
End;


 //Bairro, caso seja diferente do Complemento
 IF((TrimStr(GetString(S,536,50)) <> '') and (UpperStr(TrimStr(GetString(S,536,50))) <> UpperStr(TrimStr(GetString(S,486,50))))) then
   Begin
      EXTERNA.REC1.END_I_COMP[indexMemoEndImovel] := TrimStr(GetString(S,536,50));
      pulaLinha := 1;
   End;

//-- Atualizando o indice do memo caso necessario 
IF(pulaLinha = 1) then
Begin
     pulaLinha := 0;
     indexMemoEndImovel := indexMemoEndImovel + 1;
End;

 //Cep, Cidade - UF
 EXTERNA.REC1.END_I_COMP[indexMemoEndImovel] := TrimStr(GetString(S,586,5)) + '-' + TrimStr(GetString(S,591,3)) + ' - PARANAVAÍ/PR';

 EXTERNA.REC1.QUADRA      := TrimStr(GetString(S,664,12));
 EXTERNA.REC1.LOTE        := TrimStr(GetString(S,676,12));


//------------------------- FIM ENDEREÇO IMÓVEL ----------------


    EXTERNA.REC1.NOMEARQ     := RetornaNomeArqEntrada(0);


    
    BeginPage(EXTERNA);
    WriteRecord(EXTERNA,REC1);
    EndPage(EXTERNA);


//---------- Limpando Variaveis EXTERNA -----------


 FOR X := 1 TO 4 DO 
  BEGIN 
   EXTERNA.REC1.END_I_COMP[X]    := '';
   EXTERNA.REC1.END_ENTREG[X]    := '';
  END;

//--------------------- FIM DE LIMPEZA ------------------


//------------------- Campo de Ordenação ------------ 

     //Inscrição Imobiliaria
     sOrder := TrimStr(GetString(S,27,25));

     Markup(sOrder);
    
END;


//SOLICITAÇÃO DO CLIENTE É QUE O ARQUIVO SEJA IMPRESSO NA ORDEM DE INCRIÇÃO CADASTRAL
Convert(1,false,false,true,0,false);
