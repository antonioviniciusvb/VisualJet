{
   PROJETO: MONTES CLAROS -- IPTU
   DATA: 21/01/2020
   DESENVOLVEDOR: VINICIUS VERAS
   SCRIPT DE IMPORTAÇÃO
}

  // -----  Convenção de palavras  -------
  //1 - Linhas do tipo n = linhas n
  //    Ex: linha do tipo 1 = linha 1 

// Cria as variáveis de multi-registro

L1 := '';

L2 := '';

L3 := '';

L4 := '';

//Não utilizado
L7 := '';

LParcelas := '';

//FLAG QUE DELIMITA O FINAL DE CADA REG
sGrupo_old := '';

//PONTO DE PARTIDA

While true do
Begin

Linha := ReadLn(S);
 
//PONTO DE GRAVAÇÃO 
IF ((GetString(S,1,1) = '1') AND (sGrupo_old = '7') OR (Linha = EOF))  then
Begin

    //---------------   DESCOBRINDO A QUANTIDADE DE PARCELAS DO IPTU  ----------------------

    // -  Irei contar o número de parcelas me baseando na quantidade de vencimentos que tem nas linhas 4, pois há um campo na linha 1, posição 471 
    // que deveria conter o número de parcelas, mas só há esta informação no arquivo predial, então resolvi fazer desta maneira para utilizar tanto no 
    // arquivo Predial, quanto no Territorial.
    // - Cada linha 4 pode conter até 5 parcelas (cód barras, linh digitavel, vencimento, valor e etc) com um tamanho de 330 cada, como o limite máximo de parcelas
    // é de 7, só haverá 2 linhas 4 no máximo,
    // mas pode haver casos que tenha apenas 1, pois haverá casos que o registro só terá 1, 2, 3, n ... 7 parcelas. Isso é resultante de uma regra
    // da Lógica de négocios da Prefeitura de Montes Claros, eles sempre fixam um valor mínimo para as parcelas, neste ano foi R$ 60,00 reias, então
    // um IPTU no valor de R$ 300,00 terá 5 parcelas, eu poderia descobrir o número de parcelas com base nesta informação, mas preferi desta forma, pq o valor 
    // sempre muda, e desta forma no próximo ano, caso eu rode em outros anos e seja o mesmo layout, esta parte vai funcionar sem precisar do valor da parcela mínima.
    
    // -- Cometário registrado dia 21/01/2020 - 16:55, uma segunda-feira com um sol de rachar ...rs 
 
    nParcelas  := 0;
    tamPasso   := 330;
 
    For X := 0 TO MultLineCount(L4)- 1  do
     Begin   

       posInicial := 56; 
       posIniParc := 19; 

      For Y := 0 TO 4 do
        Begin

            IF(GetFloat(MultLineItem(L4, x), posInicial, 11)/100) > 0  then
             Begin
                nParcelas := nParcelas + 1;
                LParcelas := MultLineAdd(LParcelas , copy(MultLineItem(L4,x), posIniParc, tamPasso));
             End;

             //Atualizando posição
             posIniParc := posIniParc + tamPasso;
             posInicial := posInicial + tamPasso;
                
        End;
     End;

 
//SÓ IRÁ GRAVAR CASO TENHA 1 OU ATÉ 7 PARCELAS
IF(nParcelas > 0 ) AND (nParcelas < 8) then
Begin
     
   ClearFields(PAGE1,REC1);
    
    //SERÁ UTILIZADO NOS TEXTOS DAS PARCELAS   
        aux_Txt_Insc := GetString(L1,170,2) + '.' + GetString(L1,173,2) + '.' + GetString(L1,175,3) + '.' 
         + GetString(L1,179,4) + '.' + GetString(L1,183,3);

   //L1 
   PAGE1.REC1.NUMCADASTR  := FormatFloat(GetFloat(L1,3,16),'9999');
   PAGE1.REC1.INSCR       := aux_Txt_Insc;
   PAGE1.REC1.PROP        := TrimStr(GetString(L1,19,150));
   PAGE1.REC1.END         := TrimStr(GetString(L1,188,50));
   PAGE1.REC1.END_NUMERO  := FormatFloat(GetFloat(L1,238,6),'9999');
   PAGE1.REC1.END_COMPL   := TrimStr(Replace(GetString(L1,244,50),'''',''));   
   PAGE1.REC1.BAIRRO      := TrimStr(GetString(L1,294,60));
   PAGE1.REC1.CEP         := GetString(L1,354,5) + '-' + GetString(L1,359,3);
   PAGE1.REC1.QUADRA      := TrimStr(GetString(L1,362,4));
   PAGE1.REC1.LOTE        := TrimStr(GetString(L1,366,4));
   PAGE1.REC1.DISTRITO    := GetString(L1,170,2);
   PAGE1.REC1.SETOR       := GetString(L1,173,2);
   PAGE1.REC1.SUB_LOTE    := GetString(L1,183,3);
   PAGE1.REC1.SUB_UNIDAD  := GetString(L1,186,2);
   
   PAGE1.REC1.EXERCICIO   := '2020';
   PAGE1.REC1.ALIQUOTA    := FormatFloat(GetFloat(L2,74,6)/100,'9.999,99');
   PAGE1.REC1.VLR_VENAL   := FormatFloat(GetFloat(L1,377,15)/100,'9.999,99');
   PAGE1.REC1.VL_VN_EDIF  := FormatFloat(GetFloat(L1,392,15)/100,'9.999,99');
   PAGE1.REC1.VL_VN_IMOV  := FormatFloat(GetFloat(L1,407,15)/100,'9.999,99');
   PAGE1.REC1.IMPOSTO     := FormatFloat(GetFloat(L1,422,12)/100,'9.999,99');
   PAGE1.REC1.INCETIVO    := FormatFloat(GetFloat(L1,434,12)/100,'9.999,99');
   PAGE1.REC1.VL_S_DESC   := FormatFloat(GetFloat(L1,446,10)/100,'9.999,99');
   PAGE1.REC1.VL_C_DESC   := FormatFloat(GetFloat(L1,456,15)/100,'9.999,99');
   PAGE1.REC1.QNTD_PARC   := FormatNumeric(nParcelas,'00');

    // ÚNICA
    PAGE1.REC1.CODBARUNIC  := GetString(L3,215,44);
    PAGE1.REC1.LINDIGUNIC  := GetString(L3,259,55);
    PAGE1.REC1.NUMGUIAUNI  := GetString(L3,31,17);
    PAGE1.REC1.VLRGUIAUNI  := FormatFloat(GetFloat(L3,56,11)/100,'9.999,99');
    PAGE1.REC1.DTVENCUNIC  := GetString(L3,48,2) + '/' + GetString(L3,50,2) + '/' + GetString(L3,52,4); 


IF(nParcelas > 0) then
Begin

    //***************   HABILITANDO AS IMAGENS **********************
    //PARCELA 1 
    PAGE1.REC1.PC_1_1         := 'ITEM1';
    PAGE1.REC1.PC_2_1         := 'ITEM2';
    PAGE1.REC1.TXTBAIXA1   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR1     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT1  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU1    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF1    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE1  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC1    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC1    := 'PARCELA';
    PAGE1.REC1.TXTVENC1    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_1   := aux_Txt_Insc;

    //1
    PAGE1.REC1.CODBAR1     := GetString(MultLineItem(LPARCELAS,0),197,44); 
    PAGE1.REC1.LINDIG1     := GetString(MultLineItem(LPARCELAS,0),241,55);
    PAGE1.REC1.NUMGUIA1    := GetString(MultLineItem(LPARCELAS,0),13,17);
    PAGE1.REC1.NUMPARC1    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,0),9,3),'00');
    PAGE1.REC1.VLRGUIA1    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,0),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC1     := GetString(MultLineItem(LPARCELAS,0),30,2) + '/' + GetString(MultLineItem(LPARCELAS,0),32,2) + '/' + GetString(MultLineItem(LPARCELAS,0),34,4);
 
End;

IF(nParcelas > 1) THEN
BEGIN

    //PARCELA 2
    PAGE1.REC1.PC_1_2       := 'ITEM1';
    PAGE1.REC1.PC_2_2       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA2   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR2     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT2  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU2    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF2    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE2  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC2    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC2    := 'PARCELA';
    PAGE1.REC1.TXTVENC2    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_2   := aux_Txt_Insc;


    //2
    PAGE1.REC1.CODBAR2     := GetString(MultLineItem(LPARCELAS,1),197,44); 
    PAGE1.REC1.LINDIG2     := GetString(MultLineItem(LPARCELAS,1),241,55);
    PAGE1.REC1.NUMGUIA2    := GetString(MultLineItem(LPARCELAS,1),13,17);
    PAGE1.REC1.NUMPARC2    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,1),9,3),'00');
    PAGE1.REC1.VLRGUIA2    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,1),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC2     := GetString(MultLineItem(LPARCELAS,1),30,2) + '/' + GetString(MultLineItem(LPARCELAS,1),32,2) + '/' + GetString(MultLineItem(LPARCELAS,1),34,4);
 
END;

IF(nParcelas > 2) Then
Begin

    //PARCELA 3
    PAGE1.REC1.PC_1_3       := 'ITEM1';
    PAGE1.REC1.PC_2_3       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA3   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR3     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT3  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU3    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF3    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE3  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC3    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC3    := 'PARCELA';
    PAGE1.REC1.TXTVENC3    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_3   := aux_Txt_Insc;

    //3
    PAGE1.REC1.CODBAR3     := GetString(MultLineItem(LPARCELAS,2),197,44); 
    PAGE1.REC1.LINDIG3     := GetString(MultLineItem(LPARCELAS,2),241,55);
    PAGE1.REC1.NUMGUIA3    := GetString(MultLineItem(LPARCELAS,2),13,17);
    PAGE1.REC1.NUMPARC3    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,2),9,3),'00');
    PAGE1.REC1.VLRGUIA3    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,2),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC3     := GetString(MultLineItem(LPARCELAS,2),30,2) + '/' + GetString(MultLineItem(LPARCELAS,2),32,2) + '/' + GetString(MultLineItem(LPARCELAS,2),34,4);

End;


IF(nParcelas > 3)Then
Begin

    //PARCELA 4
    PAGE1.REC1.PC_1_4       := 'ITEM1';
    PAGE1.REC1.PC_2_4       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA4   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR4     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT4  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU4    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF4    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE4  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC4    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC4    := 'PARCELA';
    PAGE1.REC1.TXTVENC4    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_4   := aux_Txt_Insc;

    //4
    PAGE1.REC1.CODBAR4     := GetString(MultLineItem(LPARCELAS,3),197,44); 
    PAGE1.REC1.LINDIG4     := GetString(MultLineItem(LPARCELAS,3),241,55);
    PAGE1.REC1.NUMGUIA4    := GetString(MultLineItem(LPARCELAS,3),13,17);
    PAGE1.REC1.NUMPARC4    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,3),9,3),'00');
    PAGE1.REC1.VLRGUIA4    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,3),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC4     := GetString(MultLineItem(LPARCELAS,3),30,2) + '/' + GetString(MultLineItem(LPARCELAS,3),32,2) + '/' + GetString(MultLineItem(LPARCELAS,3),34,4);

End;

IF(nParcelas > 4)Then
Begin

    //PARCELA 5
    PAGE1.REC1.PC_1_5       := 'ITEM1';
    PAGE1.REC1.PC_2_5       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA5   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR5     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT5  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU5    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF5    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE5  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC5    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC5    := 'PARCELA';
    PAGE1.REC1.TXTVENC5    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_5   := aux_Txt_Insc;

    //5
    PAGE1.REC1.CODBAR5     := GetString(MultLineItem(LPARCELAS,4),197,44); 
    PAGE1.REC1.LINDIG5     := GetString(MultLineItem(LPARCELAS,4),241,55);
    PAGE1.REC1.NUMGUIA5    := GetString(MultLineItem(LPARCELAS,4),13,17);
    PAGE1.REC1.NUMPARC5    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,4),9,3),'00');
    PAGE1.REC1.VLRGUIA5    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,4),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC5     := GetString(MultLineItem(LPARCELAS,4),30,2) + '/' + GetString(MultLineItem(LPARCELAS,4),32,2) + '/' + GetString(MultLineItem(LPARCELAS,4),34,4);
 
End;

IF(nParcelas > 5) Then
Begin

    //PARCELA 6
    PAGE1.REC1.PC_1_6       := 'ITEM1';
    PAGE1.REC1.PC_2_6       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA6   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR6     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT6  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU6    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF6    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE6  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC6    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC6    := 'PARCELA';
    PAGE1.REC1.TXTVENC6    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_6   := aux_Txt_Insc;

    //6
    PAGE1.REC1.CODBAR6     := GetString(MultLineItem(LPARCELAS,5),197,44); 
    PAGE1.REC1.LINDIG6     := GetString(MultLineItem(LPARCELAS,5),241,55);
    PAGE1.REC1.NUMGUIA6    := GetString(MultLineItem(LPARCELAS,5),13,17);
    PAGE1.REC1.NUMPARC6    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,5),9,3),'00');
    PAGE1.REC1.VLRGUIA6    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,5),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC6     := GetString(MultLineItem(LPARCELAS,5),30,2) + '/' + GetString(MultLineItem(LPARCELAS,5),32,2) + '/' + GetString(MultLineItem(LPARCELAS,5),34,4);

End;

IF(nParcelas > 6) Then
Begin

    //PARCELA 7
    PAGE1.REC1.PC_1_7       := 'ITEM1';
    PAGE1.REC1.PC_2_7       := 'ITEM2';
    PAGE1.REC1.TXTBAIXA7   := 'CÓDIGO DE BAIXA';
    PAGE1.REC1.TXTVLR7     := 'VALOR DA PARCELA (R$)';
    PAGE1.REC1.TXTAUTENT7  := 'AUTENTICAÇÃO MECÂNICA';
    PAGE1.REC1.TXTIPTU7    := 'IPTU 2020';
    PAGE1.REC1.TXTPREF7    := 'PREFEITURA DE MONTES CLAROS IPTU 2020';
    PAGE1.REC1.TXTVIAPRE7  := 'VIA PREFEITURA';
    PAGE1.REC1.TXTINSC7    := 'INSCRIÇÃO IMOBILIÁRIA';
    PAGE1.REC1.TXTPARC7    := 'PARCELA';
    PAGE1.REC1.TXTVENC7    := 'VENCIMENTO';
    PAGE1.REC1.TXTINSM_7   := aux_Txt_Insc;

    //7
    PAGE1.REC1.CODBAR7     := GetString(MultLineItem(LPARCELAS,6),197,44); 
    PAGE1.REC1.LINDIG7     := GetString(MultLineItem(LPARCELAS,6),241,55);
    PAGE1.REC1.NUMGUIA7    := GetString(MultLineItem(LPARCELAS,6),13,17);
    PAGE1.REC1.NUMPARC7    := FormatNumeric(GetNumeric(MultLineItem(LPARCELAS,6),9,3),'00');
    PAGE1.REC1.VLRGUIA7    := FormatFloat(GetFloat(MultLineItem(LPARCELAS,6),38,11)/100,'9.999,99');
    PAGE1.REC1.DTVENC7     := GetString(MultLineItem(LPARCELAS,6),30,2) + '/' + GetString(MultLineItem(LPARCELAS,6),32,2) + '/' + GetString(MultLineItem(LPARCELAS,6),34,4);
    
END;


    BeginPage(PAGE1);
     WriteRecord(PAGE1,REC1);
    EndPage(PAGE1);
   

// --------------------- FIM  INTERNA  ---------------------------

// ------------------------INICIO EXTERNA  ---------------------------

    ClearFields(PAGE2,REC1);
    PAGE2.REC1.INSCR        := aux_Txt_Insc;
    PAGE2.REC1.PROP         := TrimStr(GetString(L1,19,150));
    PAGE2.REC1.END          := TrimStr(GetString(L1,188,50));
    PAGE2.REC1.END_NUMERO   := FormatFloat(GetFloat(L1,238,6),'9999');
    PAGE2.REC1.END_COMPL    := TrimStr(Replace(GetString(L1,244,50),'''',''));   
    PAGE2.REC1.BAIRRO       := TrimStr(GetString(L1,294,60));
    PAGE2.REC1.CEP          := GetString(L1,354,5) + '-' + GetString(L1,359,3);
    PAGE2.REC1.NOME_ARQ     := RetornaNomeArqEntrada(0);


    
    BeginPage(PAGE2);
     WriteRecord(PAGE2,REC1);
    EndPage(PAGE2);

  sOrder := '';


  //Ordena por End, Numero, Compl e Bairro  ----  Arquivo Predial OU
  //Ordena por Contribuinte  --- Arquivo Territorial

  IF(ORDENACAO = 0) then
  BEGIN 
      sOrder := TrimStr(GetString(L1,188,50)) + FormatFloat(GetFloat(L1,238,6),'9999') + TrimStr(Replace(GetString(L1,244,50),'''','')) + TrimStr(GetString(L1,294,60));
  END
   ELSE
     IF(ORDENACAO = 1) THEN
      BEGIN 
       sOrder := TrimStr(GetString(L1,19,150));
      END
       ELSE
         Begin
          Abort;
         End;

  Markup(sOrder);

//------------------------------- FIM EXTERNA ------------------------------

end;

       //-------------------------- Inicio - 'Limpeza de Variáveis' ----------
       
       aux_Txt_Insc := '';
       sGrupo_Old := '';
       L1        := '';
       L2        := '';
       L3        := '';
       L4        := MultLineClear(L4);
       L7        := MultLineClear(L7);
       LParcelas := MultLineClear(LParcelas);
       
       //-------------------------- Fim - 'Limpeza de Variáveis' ----------

End;


//************  PONTO DE CAPTURA DOS REGISTROS  *****************

     IF GetString(S,1,1) = '1' then  
     Begin
       L1 := S; 
     End;

    IF GetString(S,1,1) = '2' then  
     Begin
      L2 := S;
     End;

    //ÚNICA
    IF GetString(S,1,1) = '3'  then  
     Begin
        L3 := S; 
     End;

      //PARCELAS 
      IF GetString(S,1,1) = '4' then  
     Begin
        L4 := MultLineAdd(L4,S); 
        sGrupo_old := '7';
     End;

      IF GetString(S,1,1) = '7' then  
     Begin
        L7 := MultLineAdd(L7,S); 
     End;
 
//***********************    FIM DE CAPTURA  **************************
 

//****************   PONTO DE ENCERRAMENTO DO WHILE
 IF(Linha = EOF) then
  Begin
    break;
  End;
 

End;
// FAZ A PROFUNDIDADE COM 2 NA FOLHA
Convert(1,false,false,true,0,false);


