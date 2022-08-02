{
  Projeto Estrutura MPM
  Desenvolvedor: Vinicius Veras
  Data: 20/06/2018
  
  00 = Dados do Protocolo
  01 = Dados dos Titulos para o boleto
  07 = Balancete parte Interna
  08 - Balancete parte Externa


  IMPLEMENTAÇÃO DOS BANCOS: 
  ITAÚ (CARTEIRA 109); CAIXA ECONOMINCA (BOLETO REGISTRADO); SANTANDER (BOLETO REGISTRADO); SICREDI (BOLETO REGISTRADO)
  
  ATUALIZAÇÃO DIA 25/11/2018 --> INCLUSÃO BANCO BRADESCO 
}

// Cria as variáveis de multi-registro
gPRT:= ''; // PROTOCOLO
g00 := ''; // HEADER
g01 := ''; // DADOS DO BENEFICIÁRIO PAGADOR
g02 := ''; // INSTRUCOES DE BOLETO (UTILIZADO APENAS POR ARQUIVOS SICREDI E BRADESCO)
g06 := ''; // INSTRUCOES DE BOLETO (UTILIZADO APENAS POR ARQUIVOS ITAU)
g07 := ''; // BALANCETE INTERNO
g08 := ''; // BALANCETE EXTERNO


GravaProtocolo := 0;
indiceNomeArq := 0;

countReg      := 0; //Contador de Registros de cada condominio
countRegTotal := 0; //Contador de Registros Continuo

sGrupo_old := '';

While True Do
Begin

  // Carrega a linha do arquivo
  // Este IF força o laço infinito a quebrar qdo chegar o final do arquivo
  LeLinha := ReadLn(S);
 
//********************************** PROTOCOLO **************************************

IF((GravaProtocolo = 0) AND (MultLineCount(gPRT) >= 1) AND (MultLineCount(g00) = 1)) then
BEGIN
  GravaProtocolo := 1;
  
  ClearFields(PROTOCOLO,REC1);

  PROTOCOLO.REC1.DATAATUAL := SYS_DATE;
  total := 0.0;

  For x:= 0 to (MultLineCount(gPRT)-1) do
  Begin
      IF (x > 24) then
       Begin
        break;
       End
        Else
        Begin
        
          //Total de Regsitro do condominio
          qntd := GetFloat(MultLineItem(gPRT,x),45,8);

          //Total de Registros
          total := total + qntd;
  
          PROTOCOLO.REC1.CODEDI[x+1]     :=  FormatNumeric(x+1,'0000');
          PROTOCOLO.REC1.CONDOMINIO[x+1] :=  TrimStr(copy(MultLineItem(gPRT,x),10,35));
          PROTOCOLO.REC1.QTDTIT[x+1]     :=  FormatFloat(qntd,'9999');

        End;
  End;

  PROTOCOLO.REC1.TOTOBJ := FormatFloat(total,'99999');

  BeginPage(PROTOCOLO);
    WriteRecord(PROTOCOLO,REC1);
  EndPage(PROTOCOLO);
  
END;
//********************************** FIM - PROTOCOLO ****************************************

// Entra para gravar quando a linha anterior for '08' e encontrou novo '1'
IF ((sGrupo_Old = '8') AND (GetString(S,1,1) = '1') OR (GetString(S,1,1) = '9') OR (LeLinha = EOF)) THEN
BEGIN

  //Conta Registros
  countReg      := countReg + 1;

  //Continuo
  countRegTotal := countRegTotal + 1;

 //############################## BANCO SANTANDER #############################################

 IF (copy(MultLineItem(g00,0),77,3) = '033') then
 BEGIN

 //= 1 - GLOBAIS =


 Global_Nome      := TrimStr(copy(MultLineItem(g01,0),235,40));
 Global_End       := TrimStr(copy(MultLineItem(g01,0),275,40));
 Global_Bairro    := TrimStr(copy(MultLineItem(g01,0),315,12));
 Global_Cep       := copy(MultLineItem(g01,0),327,5) + '-' + copy(MultLineItem(g01,0),332,3);
 Global_Cidade    := TrimStr(copy(MultLineItem(g01,0),335,15));
 Global_Uf        := TrimStr(copy(MultLineItem(g01,0),350,2));
 Global_Benef     := TrimStr(copy(MultLineItem(g07,0),7,77));
 Global_CNPJ_Benef:= FormatCGCCPF(copy(MultLineItem(g01,0),4,14));

//= 1- FIM =
    

//== 2- Gravação de Page Interna ==

    ClearFields(INTERNA_SA,REC1);

    INTERNA_SA.REC1.NOME       := Global_Nome; 
    INTERNA_SA.REC1.END        := Global_End;
    INTERNA_SA.REC1.BAIRRO     := Global_Bairro;
    INTERNA_SA.REC1.CEP        := Global_Cep;
    INTERNA_SA.REC1.CIDADE     := Global_Cidade;
    INTERNA_SA.REC1.UF         := Global_Uf;
    
    // CNPJ OU CPF PAGADOR
    INTERNA_SA.REC1.CNPJ_CPF   := FormatCGCCPF(copy(MultLineItem(g01,0),221,14));
    INTERNA_SA.REC1.BENEFICIAR := Global_Benef + ' - CNPJ: ' + Global_CNPJ_Benef;

     sPSK := FormatFloat(GetFloat(MultLineItem(g01,0),22,8),'9999999');

     INTERNA_SA.REC1.AGECTACED  := copy(MultLineItem(g01,0),18,4) + ' / ' + sPSK;
     INTERNA_SA.REC1.ACEITE     := 'N'; 
     INTERNA_SA.REC1.BBANCO     := '033';
     INTERNA_SA.REC1.DATADOC    := GetDate(MultLineItem(g01,0),151,6);
     INTERNA_SA.REC1.NUMDOC     := TrimStr(copy(MultLineItem(gPRT,(indiceNomeArq-1)),53,25));
     INTERNA_SA.REC1.DATAPROC   := FormatDate(SYS_DATE,'DD/MM/AAAA');

      
     INTERNA_SA.REC1.BVLRTITULO := GetFloat(MultLineItem(g01,0),127,13)/100;
     INTERNA_SA.REC1.BVENC      := GetDate(MultLineItem(g01,0),121,6);
     INTERNA_SA.REC1.BPSK       := sPSK;
     INTERNA_SA.REC1.BNOSSONUM  := copy(MultLineItem(g01,0),63,7);
     INTERNA_SA.REC1.BCARTEIRA  := '101'; 
     INTERNA_SA.REC1.LOCALPAG   := 'PAGAR PREFERENCIALMENTE NO GRUPO SANTANDER';
     
       
 //=== 3- ARMAZENAMENTO DE 2 LINHAS DO LIST G07 ===
  
        //Armazenarei as 2 primeiras linhas  do g07 em 2 lists, pois irei utilizar em mais de um lugar, terei um acesso mais fácil a eles
        //
        // ---------------------------  ATENÇÃO --------------------------------------------------- 
        //Em uma linha são  6 campos, dividirei em 3 linhas para cada um dos lists
        //
        //    L1E = 75    L1D = 51 L2E = 75 L2D = 51  L3E = 75  L3D = 51   
        //    01------------|-------02---------|------03---------|------FIM
        //
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 75 BYTES
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 51 BYTES
       
        //***Este procedimento será utilizado nas outras linhas do g07, mudando apenas o tamanho dos bytes e que os lançamentos serão gravados diretamente
        //**** nos campos MEMOS, pois só irei utiliza-los uma vez 
       
      msgTamSupE   := 77;
      msgTamSupD   := 51;
      msgPosSup    := 7;
      g07Esquerdo  := '';
      g07Direito   := '';
    

       FOR x := 0 to 1 do
         Begin

           //= 3-1 - MENSAGM 1 =

           //LADO ESQUERDO
           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 77 + 7
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));
         
           // POSIÇÃO = 84 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // - 3-1 - FIM -


           //== 3-2 - MENSAGM 2 ==

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 137 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

         
           // POSIÇÃO = 214 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // -- 3-2 - FIM --

           
           //=== 3-3 - MENSAGM 3 ===

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 267 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

           // POSIÇÃO = 7 
           msgPosSup    :=  7;

           // --- 3-3 - FIM ---
     
         End;
   
//=== 3 - FIM  ===




//==== 4 - BALANCETE PRINCIPAL ====

      msgTam     := 64;
      msgPos     := 7;
      indiceBal  := 1;
   
      For x := 2 to 17  do
       Begin

       IF x < 17 THEN
        BEGIN
         //---- 4-1 - MENSAGEM 1  ----

         //LADO ESQUERDO

         INTERNA_SA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         // POSIÇÃO = 64+7
         msgPos     := msgPos + msgTam ; 
         
         //LADO DIREITO
         INTERNA_SA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         indiceBal := indiceBal + 1;
         
         // POSIÇÃO = 71+64+2
         msgPos     := msgPos + msgTam + 2;

         //---- 4-1 - FIM ----
         
         //---- 4-2 -  MENSAGEM 2 ----
         
         //LADO ESQUERDO

         INTERNA_SA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 137 + 64
         msgPos := msgPos + msgTam;         

         //LADO DIREITO
         INTERNA_SA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
        

          //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         //POSIÇÃO = 201 + 64 +2
         msgPos := msgPos + msgTam + 2;

         indiceBal := indiceBal + 1;
         
         //---- 4-2 - FIM ----
              

         //---- 4-3 - MENSAGEM 3 ----
         
         //LADO ESQUERDO
         INTERNA_SA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 267 + 64
         msgPos := msgPos + msgTam;

         //LADO DIREITO
         INTERNA_SA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
          

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         indiceBal := indiceBal + 1; 

         //POSIÇÃO INICIAL
         msgPos := 7;


        //---- 4-3 - FIM ----
 
       End;
   END;    

//==== 4 - FIM ====


//===== 5 - BALANCETE SUPERIOR =====

        //Limitei em 4 linhas, pois o layout do arquivo está diferente do apresentado, então as últimas 2 linhas do g07Esquerdo
        //devem ser apresentadas na taxa condominial

        For x := 0 to 3  do
         Begin
           INTERNA_SA.REC1.BALESUP[x+1] := MultLineItem(g07Esquerdo,x);
         End;

           //Atualizei fora do for para não precisar de um IF dentro do for acima, ganhei uns milisengundos de processamento ...rs
           INTERNA_SA.REC1.BALESUP[1] := TrimStr(MultLineItem(g07Esquerdo,0)) + ' - ' + Global_CNPJ_Benef;


//===== 5 - FIM =====


//====== 6 - COMPOSIÇÃO DA TAXA CONDOMINIAL ======

       indiceTaxaCon := 1;   

 
       For x := 0 to 5  do
         Begin
          IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
            Begin
              INTERNA_SA.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Direito,x);
              indiceTaxaCon := indiceTaxaCon + 1;
            End;
         End;

        //Só irá lançar caso haja dados além dos 4 default
        IF MultLineCount(g07Esquerdo) > 4 then
        Begin
          for x:= 0 to 1 do
           begin
               if (Length(MultLineItem(g07Esquerdo,x+4))) > 0 then
               begin
                  INTERNA_SA.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Esquerdo,x+4);
                  indiceTaxaCon := indiceTaxaCon + 1;
               end;
           end;

        End;
        

//====== 6 - FIM ======

//======= 7 - INSTRUÇÕES DO BOLETO  =======

      //Nas Instruções utilizarei o g00, que corresponde ao header onde tem 6 campos de mensagens com tamanho fixo de 47 byte cada

      msgInstrucoesPosInicial := 117;
      msgInstrucoesTamanho    := 47;
      indiceInstrucao := 1;

      //Somente até 5, pois irei desconsiderar o ultimo campo que está saindo incompleto, onde irei captura-lo no g07Direito
      For x := 0 to 4  do
         Begin
           
           auxMsgInstrucoes := TrimStr(copy(MultLineItem(g00,0), msgInstrucoesPosInicial,msgInstrucoesTamanho));

           //Só irá gravar caso tenha algo
           IF Length(auxMsgInstrucoes) > 0 THEN
              Begin
                INTERNA_SA.REC1.INSTRUCOES[indiceInstrucao] := auxMsgInstrucoes;
                indiceInstrucao := indiceInstrucao + 1;
              end;
            
           //Atualizo posição inicial para apontar para o próximo campo
           msgInstrucoesPosInicial := msgInstrucoesPosInicial + msgInstrucoesTamanho;            
 
           End;

           For x := 0 to (MultLineCount(g07Direito)-1) do        
           Begin
           //Só irá gravar caso tenha algo
           IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
              Begin
                INTERNA_SA.REC1.INSTRUCOES[indiceInstrucao] := MultLineItem(G07Direito,x);
                indiceInstrucao := indiceInstrucao + 1;
              end;           
           End;
//======= 7 - FIM =======


     
          BeginPage(INTERNA_SA);
            WriteRecord(INTERNA_SA,REC1);  
          EndPage(INTERNA_SA);


//== 2 - FIM ==


//======== 8 -  EXTERNA ========

      ClearFields(EXTERNA,REC1);
     
      EXTERNA.REC1.SEQ         := FormatNumeric(countReg,'#####');
      EXTERNA.REC1.SEQ_2       := countRegTotal;

      EXTERNA.REC1.BENEFICIAR  := Global_Benef; 
      EXTERNA.REC1.NOME        := Global_Nome;
      EXTERNA.REC1.END         := Global_End;
      EXTERNA.REC1.BAIRRO      := Global_Bairro;
      EXTERNA.REC1.CEP         := Global_Cep;
      EXTERNA.REC1.CIDADE      := Global_Cidade;
      EXTERNA.REC1.UF          := Global_Uf;

 

//========= 9 -  MENSAGEM BALANCETE EXTERNO  =========          

      msgTamExterna    := 140;
      msgPosExterna    := 4;
      indiceBalExterna := 1;

      For x := 0 to 11  do
       Begin
         
          EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
         
         // POSIÇÃO = 140 + 4 + 52 (Brancos e Descartaveis)
         msgPosExterna     := msgPosExterna + msgTamExterna + 52; 
         
       
         EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
              
         // POSIÇÃO INICIAL
         msgPosExterna     := 4;

       END;
//======== 9 - FIM ========

       BeginPage(EXTERNA);
       WriteRecord(EXTERNA,REC1);
       EndPage(EXTERNA);

//======= 8 - FIM =======




//========== 10 -  Limpa os  memos ==========

      for x:= 1 to 45 do
      begin
        INTERNA_SA.REC1.LINBAL[x] := '';
        INTERNA_SA.REC1.LINBALD[x] := '';
      end;
       
      for x:= 0 to 5 do
      begin
        INTERNA_SA.REC1.BALESUP[x+1] := '';
      end;

      for x:= 0 to 7 do
      begin
        INTERNA_SA.REC1.TAXACOND[x+1]:= '';
      end;
  
     for x:= 0 to 9 do
     begin
        INTERNA_SA.REC1.INSTRUCOES[x+1] := '';
     end;

    for x:= 0 to 24  do
      begin
        EXTERNA.REC1.LINBALV[x+1] := '';
      end;

//========== 10 - FIM ==========

//############################################## FIM BANCO SANTANDER ###########################################

END
 ELSE

//############################################## BANCO CAIXA ELETRÔNICA ###########################################
   IF (copy(MultLineItem(g00,0),77,3) = '104') THEN
    BEGIN

 //= 1 - GLOBAIS =


 Global_Nome      := TrimStr(copy(MultLineItem(g01,0),235,40));
 Global_End       := TrimStr(copy(MultLineItem(g01,0),275,40));
 Global_Bairro    := TrimStr(copy(MultLineItem(g01,0),315,12));
 Global_Cep       := copy(MultLineItem(g01,0),327,5) + '-' + copy(MultLineItem(g01,0),332,3);
 Global_Cidade    := TrimStr(copy(MultLineItem(g01,0),335,15));
 Global_Uf        := TrimStr(copy(MultLineItem(g01,0),350,2));
 Global_Benef     := TrimStr(copy(MultLineItem(g07,0),7,77));
 Global_CNPJ_Benef:= FormatCGCCPF(copy(MultLineItem(g01,0),4,14));

//= 1- FIM =
    

//== 2- Gravação de Page Interna ==

    ClearFields(INTERNA_CX,REC1);

    INTERNA_CX.REC1.NOME       := Global_Nome; 
    INTERNA_CX.REC1.END        := Global_End;
    INTERNA_CX.REC1.BAIRRO     := Global_Bairro;
    INTERNA_CX.REC1.CEP        := Global_Cep;
    INTERNA_CX.REC1.CIDADE     := Global_Cidade;
    INTERNA_CX.REC1.UF         := Global_Uf;
    
    // CNPJ OU CPF PAGADOR
    INTERNA_CX.REC1.CNPJ_CPF   := FormatCGCCPF(copy(MultLineItem(g01,0),221,14));
    INTERNA_CX.REC1.BENEFICIAR := Global_Benef + ' - CNPJ: ' + Global_CNPJ_Benef;

    


     sCodBenf := FormatFloat(GetFloat(MultLineItem(g01,0),22,6),'999999');

     INTERNA_CX.REC1.AGECTACED  := copy(MultLineItem(g01,0),18,4) + ' / ' + sCodBenf;
     INTERNA_CX.REC1.ACEITE     := copy(MultLineItem(g01,0),150,1);
     INTERNA_CX.REC1.BBANCO     := '104';
     INTERNA_CX.REC1.DATADOC    := GetDate(MultLineItem(g01,0),151,6);
     INTERNA_CX.REC1.NUMDOC     := TrimStr(copy(MultLineItem(gPRT,(indiceNomeArq-1)),53,25));
     INTERNA_CX.REC1.DATAPROC   := FormatDate(SYS_DATE,'DD/MM/AAAA');

      
     INTERNA_CX.REC1.BVLRTITULO := GetFloat(MultLineItem(g01,0),127,13)/100;
     INTERNA_CX.REC1.BVENC      := GetDate(MultLineItem(g01,0),121,6);
     INTERNA_CX.REC1.BCODBENEF  := sCodBenf;
     INTERNA_CX.REC1.BNOSSONUM  := copy(MultLineItem(g01,0),59,15);
     INTERNA_CX.REC1.BCARTEIRA  := '1'; 
     INTERNA_CX.REC1.LOCALPAG   := 'PAGAR PREFERENCIALMENTE NA CAIXA';
     
     
       
 //=== 3- ARMAZENAMENTO DE 2 LINHAS DO LIST G07 ===
  
        //Armazenarei as 2 primeiras linhas  do g07 em 2 lists, pois irei utilizar em mais de um lugar, terei um acesso mais fácil a eles
        //
        // ---------------------------  ATENÇÃO --------------------------------------------------- 
        //Em uma linha são  6 campos, dividirei em 3 linhas para cada um dos lists
        //
        //    L1E = 75    L1D = 51 L2E = 75 L2D = 51  L3E = 75  L3D = 51   
        //    01------------|-------02---------|------03---------|------FIM
        //
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 75 BYTES
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 51 BYTES
       
        //***Este procedimento será utilizado nas outras linhas do g07, mudando apenas o tamanho dos bytes e que os lançamentos serão gravados diretamente
        //**** nos campos MEMOS, pois só irei utiliza-los uma vez 
       
      msgTamSupE   := 77;
      msgTamSupD   := 51;
      msgPosSup    := 7;
      g07Esquerdo  := '';
      g07Direito   := '';
    

       FOR x := 0 to 1 do
         Begin

           //= 3-1 - MENSAGM 1 =

           //LADO ESQUERDO
           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 77 + 7
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));
         
           // POSIÇÃO = 84 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // - 3-1 - FIM -


           //== 3-2 - MENSAGM 2 ==

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 137 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

         
           // POSIÇÃO = 214 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // -- 3-2 - FIM --

           
           //=== 3-3 - MENSAGM 3 ===

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 267 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

           // POSIÇÃO = 7 
           msgPosSup    :=  7;

           // --- 3-3 - FIM ---
     
         End;
   
//=== 3 - FIM  ===




//==== 4 - BALANCETE PRINCIPAL ====

      msgTam     := 64;
      msgPos     := 7;
      indiceBal  := 1;
   
      For x := 2 to 17  do
       Begin

       IF x < 17 THEN
        BEGIN
         //---- 4-1 - MENSAGEM 1  ----

         //LADO ESQUERDO

         INTERNA_CX.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         // POSIÇÃO = 64+7
         msgPos     := msgPos + msgTam ; 
         
         //LADO DIREITO
         INTERNA_CX.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         indiceBal := indiceBal + 1;
         
         // POSIÇÃO = 71+64+2
         msgPos     := msgPos + msgTam + 2;

         //---- 4-1 - FIM ----
         
         //---- 4-2 -  MENSAGEM 2 ----
         
         //LADO ESQUERDO

         INTERNA_CX.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 137 + 64
         msgPos := msgPos + msgTam;         

         //LADO DIREITO
         INTERNA_CX.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
        

          //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         //POSIÇÃO = 201 + 64 +2
         msgPos := msgPos + msgTam + 2;

         indiceBal := indiceBal + 1;
         
         //---- 4-2 - FIM ----
              

         //---- 4-3 - MENSAGEM 3 ----
         
         //LADO ESQUERDO
         INTERNA_CX.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 267 + 64
         msgPos := msgPos + msgTam;

         //LADO DIREITO
         INTERNA_CX.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
          

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         indiceBal := indiceBal + 1; 

         //POSIÇÃO INICIAL
         msgPos := 7;


        //---- 4-3 - FIM ----
 
       End;
   END;    

//==== 4 - FIM ====


//===== 5 - BALANCETE SUPERIOR =====

        //Limitei em 4 linhas, pois o layout do arquivo está diferente do apresentado, então as últimas 2 linhas do g07Esquerdo
        //devem ser apresentadas na taxa condominial

        For x := 0 to 3  do
         Begin
           INTERNA_CX.REC1.BALESUP[x+1] := MultLineItem(g07Esquerdo,x);
         End;

           //Atualizei fora do for para não precisar de um IF dentro do for acima, ganhei uns milisengundos de processamento ...rs
           INTERNA_CX.REC1.BALESUP[1] := TrimStr(MultLineItem(g07Esquerdo,0)) + ' - ' + Global_CNPJ_Benef;


//===== 5 - FIM =====


//====== 6 - COMPOSIÇÃO DA TAXA CONDOMINAL ======

       indiceTaxaCon := 1;   

 
       For x := 0 to 5  do
         Begin
          IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
            Begin
              INTERNA_CX.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Direito,x);
              indiceTaxaCon := indiceTaxaCon + 1;
            End;
         End;


        //Só irá lançar caso haja dados além dos 4 default
        IF MultLineCount(g07Esquerdo) > 4 then
        Begin
          for x:= 0 to 1 do
           begin
               if (Length(MultLineItem(g07Esquerdo,x+4))) > 0 then
               begin
                  INTERNA_CX.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Esquerdo,x+4);
                  indiceTaxaCon := indiceTaxaCon + 1;
               end;
           end;

        End;
        


//====== 6 - FIM ======

//======= 7 - INSTRUÇÕES DO BOLETO  =======

      //Nas Instruções utilizarei o g00, que corresponde ao header onde tem 6 campos de mensagens com tamanho fixo de 47 byte cada

      msgInstrucoesPosInicial := 117;
      msgInstrucoesTamanho    := 47;
      indiceInstrucao := 1;

      //Somente até 4, pois irei desconsiderar o ultimo campo que está saindo incompleto, onde irei captura-lo no g07Direito
      For x := 0 to 4  do
         Begin
           
           auxMsgInstrucoes := TrimStr(copy(MultLineItem(g00,0), msgInstrucoesPosInicial,msgInstrucoesTamanho));

           //Só irá gravar caso tenha algo
           IF Length(auxMsgInstrucoes) > 0 THEN
              Begin
                INTERNA_CX.REC1.INSTRUCOES[indiceInstrucao] := auxMsgInstrucoes;
                indiceInstrucao := indiceInstrucao + 1;
              end;
            
           //Atualizo posição inicial para apontar para o próximo campo
           msgInstrucoesPosInicial := msgInstrucoesPosInicial + msgInstrucoesTamanho;            
                
           End;

        For x := 0 to (MultLineCount(g07Direito)-1) do
         Begin
           //Só irá gravar caso tenha algo
           IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
              Begin
                INTERNA_CX.REC1.INSTRUCOES[indiceInstrucao] := MultLineItem(g07Direito,x);
                indiceInstrucao := indiceInstrucao + 1;
              end;           
           End;

//======= 7 - FIM =======


     
          BeginPage(INTERNA_CX);
            WriteRecord(INTERNA_CX,REC1);  
          EndPage(INTERNA_CX);


//== 2 - FIM ==


//======== 8 -  EXTERNA ========

      ClearFields(EXTERNA,REC1);
      EXTERNA.REC1.SEQ         := FormatNumeric(countReg,'#####');
      EXTERNA.REC1.SEQ_2       := countRegTotal;
      EXTERNA.REC1.BENEFICIAR  := Global_Benef; 
      EXTERNA.REC1.NOME        := Global_Nome;
      EXTERNA.REC1.END         := Global_End;
      EXTERNA.REC1.BAIRRO      := Global_Bairro;
      EXTERNA.REC1.CEP         := Global_Cep;
      EXTERNA.REC1.CIDADE      := Global_Cidade;
      EXTERNA.REC1.UF          := Global_Uf;
 

//========= 9 -  MENSAGEM BALANCETE EXTERNO  =========          

      msgTamExterna    := 140;
      msgPosExterna    := 4;
      indiceBalExterna := 1;

      For x := 0 to 11  do
       Begin
         
          EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
         
         // POSIÇÃO = 140 + 4 + 52 (Brancos e Descartaveis)
         msgPosExterna     := msgPosExterna + msgTamExterna + 52; 
         
       
         EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
              
         // POSIÇÃO INICIAL
         msgPosExterna     := 4;

       END;
//======== 9 - FIM ========

       BeginPage(EXTERNA);
       WriteRecord(EXTERNA,REC1);
       EndPage(EXTERNA);

//======= 8 - FIM =======




//========== 10 -  Limpa os memos ==========

      for x:= 1 to 45 do
      begin
        INTERNA_CX.REC1.LINBAL[x] := '';
        INTERNA_CX.REC1.LINBALD[x] := '';
      end;
       
      for x:= 0 to 5 do
      begin
        INTERNA_CX.REC1.BALESUP[x+1] := '';
      end;

      for x:= 0 to 7  do
      begin
        INTERNA_CX.REC1.TAXACOND[x+1]:= '';
      end;
  
      for x:= 0 to 9 do
      begin
        INTERNA_CX.REC1.INSTRUCOES[x+1] := '';
      end;

      for x:= 0 to 24  do
      begin
        EXTERNA.REC1.LINBALV[x+1] := '';
      end;

    END
     ELSE

//############################################## BANCO ITAU CARTEIRA 109 ###########################################
   IF (copy(MultLineItem(g00,0),77,3) = '341') THEN
    BEGIN
 //= 1 - GLOBAIS =


 Global_Nome      := TrimStr(copy(MultLineItem(g01,0),235,40));
 Global_End       := TrimStr(copy(MultLineItem(g01,0),275,40));
 Global_Bairro    := TrimStr(copy(MultLineItem(g01,0),315,12));
 Global_Cep       := copy(MultLineItem(g01,0),327,5) + '-' + copy(MultLineItem(g01,0),332,3);
 Global_Cidade    := TrimStr(copy(MultLineItem(g01,0),335,15));
 Global_Uf        := TrimStr(copy(MultLineItem(g01,0),350,2));
 Global_Benef     := TrimStr(copy(MultLineItem(g07,0),7,77));
 Global_CNPJ_Benef:= FormatCGCCPF(copy(MultLineItem(g01,0),4,14));

//= 1- FIM =
    

//== 2- Gravação de Page Interna ==

     ClearFields(INTERNA_IT,REC1);

     INTERNA_IT.REC1.NOME       := Global_Nome; 
     INTERNA_IT.REC1.END        := Global_End;
     INTERNA_IT.REC1.BAIRRO     := Global_Bairro;
     INTERNA_IT.REC1.CEP        := Global_Cep;
     INTERNA_IT.REC1.CIDADE     := Global_Cidade;
     INTERNA_IT.REC1.UF         := Global_Uf;
    
     // CNPJ OU CPF PAGADOR
     INTERNA_IT.REC1.CNPJ_CPF   := FormatCGCCPF(copy(MultLineItem(g01,0),221,14));
     INTERNA_IT.REC1.BENEFICIAR := Global_Benef + ' - CNPJ: ' + Global_CNPJ_Benef;

     // conta benef com digito
     INTERNA_IT.REC1.CONTABENFE :=  copy(MultLineItem(g01,0),24,6);

     INTERNA_IT.REC1.AGECTACED  := copy(MultLineItem(g01,0),18,4) + ' / ' + copy(MultLineItem(g01,0),24,5) + '-' + copy(MultLineItem(g01,0),29,1) ;
     INTERNA_IT.REC1.ACEITE     := copy(MultLineItem(g01,0),150,1); 


     INTERNA_IT.REC1.DATADOC    := GetDate(MultLineItem(g01,0),151,6);
     INTERNA_IT.REC1.NUMDOC     := TrimStr(copy(MultLineItem(gPRT,(indiceNomeArq-1)),53,25));
     INTERNA_IT.REC1.DATAPROC   := FormatDate(SYS_DATE,'DD/MM/AAAA');

     INTERNA_IT.REC1.BBANCO     := '341';
     INTERNA_IT.REC1.BAGENCIA   := copy(MultLineItem(g01,0),18,4);
     INTERNA_IT.REC1.BVLRTITULO := GetFloat(MultLineItem(g01,0),127,13)/100;
     INTERNA_IT.REC1.BVENC      := GetDate(MultLineItem(g01,0),121,6);
     INTERNA_IT.REC1.BCARTEIRA  := copy(MultLineItem(g01,0),84,3); 
     INTERNA_IT.REC1.BNOSSONUM  := copy(MultLineItem(g01,0),63,8);
     INTERNA_IT.REC1.LOCALPAG   := 'PAGAR PREFERENCIALMENTE NO BANCO ITAÚ';
       
 //=== 3- ARMAZENAMENTO DE 2 LINHAS DO LIST G07 ===
  
        //Armazenarei as 2 primeiras linhas  do g07 em 2 lists, pois irei utilizar em mais de um lugar, terei um acesso mais fácil a eles
        //
        // ---------------------------  ATENÇÃO --------------------------------------------------- 
        //Em uma linha são  6 campos, dividirei em 3 linhas para cada um dos lists
        //
        //    L1E = 75    L1D = 51 L2E = 75 L2D = 51  L3E = 75  L3D = 51   
        //    01------------|-------02---------|------03---------|------FIM
        //
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 75 BYTES
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 51 BYTES
       
        //***Este procedimento será utilizado nas outras linhas do g07, mudando apenas o tamanho dos bytes e que os lançamentos serão gravados diretamente
        //**** nos campos MEMOS, pois só irei utiliza-los uma vez 
       
      msgTamSupE   := 77;
      msgTamSupD   := 51;
      msgPosSup    := 7;
      g07Esquerdo  := '';
      g07Direito   := '';
    

       FOR x := 0 to 1 do
         Begin

           //= 3-1 - MENSAGM 1 =

           //LADO ESQUERDO
           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 77 + 7
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));
         
           // POSIÇÃO = 84 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // - 3-1 - FIM -


           //== 3-2 - MENSAGM 2 ==

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 137 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

         
           // POSIÇÃO = 214 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // -- 3-2 - FIM --

           
           //=== 3-3 - MENSAGM 3 ===

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 267 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

           // POSIÇÃO = 7 
           msgPosSup    :=  7;

           // --- 3-3 - FIM ---
     
         End;
     


   
//=== 3 - FIM  ===




//==== 4 - BALANCETE PRINCIPAL ====

      msgTam     := 64;
      msgPos     := 7;
      indiceBal  := 1;


     For x := 0 to (MultLineCount(g07Esquerdo)-1) do
      Begin
        IF(PosStr('>>>', TrimStr(MultLineItem(g07Esquerdo,x))) <> 0) then
         Begin
            INTERNA_IT.REC1.TITULO_BAL := TrimStr(MultLineItem(g07Esquerdo,x));
            g07Esquerdo := MultLineDelete(g07Esquerdo,x);
            break;
         End;
      End;

   
      For x := 2 to 17  do
       Begin

       IF x < 17 THEN
        BEGIN
         //---- 4-1 - MENSAGEM 1  ----

         //LADO ESQUERDO

         INTERNA_IT.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         // POSIÇÃO = 64+7
         msgPos     := msgPos + msgTam ; 
         
         //LADO DIREITO
         INTERNA_IT.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         indiceBal := indiceBal + 1;
         
         // POSIÇÃO = 71+64+2
         msgPos     := msgPos + msgTam + 2;

         //---- 4-1 - FIM ----
         
         //---- 4-2 -  MENSAGEM 2 ----
         
         //LADO ESQUERDO

         INTERNA_IT.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 137 + 64
         msgPos := msgPos + msgTam;         

         //LADO DIREITO
         INTERNA_IT.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
        

          //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         //POSIÇÃO = 201 + 64 +2
         msgPos := msgPos + msgTam + 2;

         indiceBal := indiceBal + 1;
         
         //---- 4-2 - FIM ----
              

         //---- 4-3 - MENSAGEM 3 ----
         
         //LADO ESQUERDO
         INTERNA_IT.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 267 + 64
         msgPos := msgPos + msgTam;

         //LADO DIREITO
         INTERNA_IT.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
          

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         indiceBal := indiceBal + 1; 

         //POSIÇÃO INICIAL
         msgPos := 7;


        //---- 4-3 - FIM ----
 
       End;
   END;    

//==== 4 - FIM ====


//===== 5 - BALANCETE SUPERIOR =====

        //Limitei em 4 linhas, pois o layout do arquivo está diferente do apresentado, então as últimas 2 linhas do g07Esquerdo
        //devem ser apresentadas na taxa condominial

        For x := 0 to 3  do
         Begin
           INTERNA_IT.REC1.BALESUP[x+1] := MultLineItem(g07Esquerdo,x);
         End;

           //Atualizei fora do for para não precisar de um IF dentro do for acima, ganhei uns milisengundos de processamento ...rs
           INTERNA_IT.REC1.BALESUP[1] := TrimStr(MultLineItem(g07Esquerdo,0)) + ' - ' + Global_CNPJ_Benef;


//===== 5 - FIM =====


//====== 6 - COMPOSIÇÃO DA TAXA CONDOMINIAL ======

       indiceTaxaCon := 1;   

       For x := 0 to 5  do
         Begin
          IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
            Begin
              INTERNA_IT.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Direito,x);
              indiceTaxaCon := indiceTaxaCon + 1;
            End;
         End;

        //Só irá lançar caso haja dados além dos 4 default
        IF MultLineCount(g07Esquerdo) > 4 then
        Begin
          for x:= 0 to 1 do
           begin
               if (Length(MultLineItem(g07Esquerdo,x+4))) > 0 then
               begin
                  INTERNA_IT.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Esquerdo,x+4);
                  indiceTaxaCon := indiceTaxaCon + 1;
               end;
           end;
        End;
        
//====== 6 - FIM ======

//======= 7 - INSTRUÇÕES DO BOLETO  =======

      //Nas Instruções utilizarei o g06, onde tem 6 campos de mensagens com tamanho fixo de 50 byte cada

      msgInstrucoesPosInicial := 2;
      msgInstrucoesTamanho    := 50;
      indiceInstrucao := 1;

        For x := 0 to 5  do
         Begin
           
           auxMsgInstrucoes := TrimStr(copy(g06, msgInstrucoesPosInicial, msgInstrucoesTamanho));

           //Só irá gravar caso tenha algo
           IF Length(auxMsgInstrucoes) > 0 THEN
              Begin
                INTERNA_IT.REC1.INSTRUCOES[indiceInstrucao] := auxMsgInstrucoes;
                indiceInstrucao := indiceInstrucao + 1;
              end;
            
           //Atualizo posição inicial para apontar para o próximo campo
           msgInstrucoesPosInicial := msgInstrucoesPosInicial + msgInstrucoesTamanho;            
  
         End;

        For x := 0 to (MultLineCount(g07Direito)-1) do
         Begin
           //Só irá gravar caso tenha algo
           IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
              Begin
                INTERNA_IT.REC1.INSTRUCOES[indiceInstrucao] := MultLineItem(G07Direito,x);
                indiceInstrucao := indiceInstrucao + 1;
              end;           
           End;

//======= 7 - FIM =======


     
          BeginPage(INTERNA_IT);
            WriteRecord(INTERNA_IT,REC1);  
          EndPage(INTERNA_IT);


//== 2 - FIM ==


//======== 8 -  EXTERNA ========

      ClearFields(EXTERNA,REC1);
      EXTERNA.REC1.SEQ         := FormatNumeric(countReg,'#####');
      EXTERNA.REC1.SEQ_2       := countRegTotal;
      EXTERNA.REC1.BENEFICIAR  := Global_Benef; 
      EXTERNA.REC1.NOME        := Global_Nome;
      EXTERNA.REC1.END         := Global_End;
      EXTERNA.REC1.BAIRRO      := Global_Bairro;
      EXTERNA.REC1.CEP         := Global_Cep;
      EXTERNA.REC1.CIDADE      := Global_Cidade;
      EXTERNA.REC1.UF          := Global_Uf;
 

//========= 9 -  MENSAGEM BALANCETE EXTERNO  =========          

      msgTamExterna    := 140;
      msgPosExterna    := 4;
      indiceBalExterna := 1;

      For x := 0 to 11  do
       Begin
         
          EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
         
         // POSIÇÃO = 140 + 4 + 52 (Brancos e Descartaveis)
         msgPosExterna     := msgPosExterna + msgTamExterna + 52; 
         
       
         EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
              
         // POSIÇÃO INICIAL
         msgPosExterna     := 4;

       END;
//======== 9 - FIM ========

       BeginPage(EXTERNA);
       WriteRecord(EXTERNA,REC1);
       EndPage(EXTERNA);

//======= 8 - FIM =======




//========== 10 -  Limpa os  memos ==========

      for x:= 1 to 45 do
      begin
        INTERNA_IT.REC1.LINBAL[x] := '';
        INTERNA_IT.REC1.LINBALD[x] := '';
      end;
       
      for x:= 0 to 5 do
      begin
        INTERNA_IT.REC1.BALESUP[x+1] := '';
      end;

      for x:= 0 to 7 do
      begin
        INTERNA_IT.REC1.TAXACOND[x+1]:= '';
      end;

    for x:= 0 to 9 do
     begin
        INTERNA_IT.REC1.INSTRUCOES[x+1] := '';
     end;
  

    for x:= 0 to 24  do
      begin
        EXTERNA.REC1.LINBALV[x+1] := '';
      end;

//========== 10 - FIM ==========

        END
     ELSE

//############################################## BANCO SICREDI -- DATA INICIO: 01/10/2018 ###########################################
   IF (copy(MultLineItem(g00,0),77,3) = '748') THEN
    BEGIN
 //= 1 - GLOBAIS =


 Global_Nome      := TrimStr(copy(MultLineItem(g01,0),235,40));
 Global_End       := TrimStr(copy(MultLineItem(g01,0),275,40));
 Global_Cep       := copy(MultLineItem(g01,0),327,5) + '-' + copy(MultLineItem(g01,0),332,3);
 Global_Bairro := TrimStr(copy(MultLineItem(g01,0),337,12));
 Global_Cidade := TrimStr(copy(MultLineItem(g01,0),349,15));
 Global_Uf     :=  copy(MultLineItem(g01,0),364,2);

 Global_Benef     := TrimStr(copy(MultLineItem(g07,0),7,77));



 Global_CNPJ_Benef:= FormatCGCCPF(copy(MultLineItem(g00,0),32,14));

//= 1- FIM =
    

//== 2- Gravação de Page Interna ==

     ClearFields(INTERNA_SI,REC1);

     INTERNA_SI.REC1.NOME       := Global_Nome; 
     INTERNA_SI.REC1.END        := Global_End;
     INTERNA_SI.REC1.BAIRRO     := Global_Bairro;
     INTERNA_SI.REC1.CEP        := Global_Cep;
     INTERNA_SI.REC1.CIDADE     := Global_Cidade;
     INTERNA_SI.REC1.UF         := Global_Uf;
    
     // CNPJ OU CPF PAGADOR
     INTERNA_SI.REC1.CNPJ_CPF   := FormatCGCCPF(copy(MultLineItem(g01,0),221,14));
     INTERNA_SI.REC1.BENEFICIAR := Global_Benef + ' - CNPJ: ' + Global_CNPJ_Benef;

     // conta benef com digito
     INTERNA_SI.REC1.CONTABENFE := '';
     INTERNA_SI.REC1.AGECTACED  := copy(MultLineItem(g01,0),366,4) + '.' + copy(MultLineItem(g01,0),335,2) + '.' + copy(MultLineItem(g00,0),27,5);


     INTERNA_SI.REC1.ACEITE     := copy(MultLineItem(g01,0),150,1); 

     INTERNA_SI.REC1.DATADOC    := GetDate(MultLineItem(g01,0),151,6);
     INTERNA_SI.REC1.NUMDOC     := TrimStr(copy(MultLineItem(gPRT,(indiceNomeArq-1)),53,25));
     INTERNA_SI.REC1.DATAPROC   := FormatDate(SYS_DATE,'DD/MM/AAAA');

     INTERNA_SI.REC1.BBANCO     := '748';
     INTERNA_SI.REC1.BAGENCIA   := copy(MultLineItem(g01,0),366,4);
     INTERNA_SI.REC1.BPOSTO     := copy(MultLineItem(g01,0),335,2);
     INTERNA_SI.REC1.BVLRTITULO := GetFloat(MultLineItem(g01,0),127,13)/100;
     INTERNA_SI.REC1.BVENC      := GetDate(MultLineItem(g01,0),121,6);
     INTERNA_SI.REC1.BTIPCOBRAN := '1';
     INTERNA_SI.REC1.BCARTEIRA  := '1'; 
     INTERNA_SI.REC1.BCODBENEF  := copy(MultLineItem(g00,0),27,5);
     INTERNA_SI.REC1.BNOSSONUM  := copy(MultLineItem(g01,0),48,9);
     INTERNA_SI.REC1.LOCALPAG   := 'PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DE CRÉDITO DO SICREDI';
       
 //=== 3- ARMAZENAMENTO DE 2 LINHAS DO LIST G07 ===
  
        //Armazenarei as 2 primeiras linhas  do g07 em 2 lists, pois irei utilizar em mais de um lugar, terei um acesso mais fácil a eles
        //
        // ---------------------------  ATENÇÃO --------------------------------------------------- 
        //Em uma linha são  6 campos, dividirei em 3 linhas para cada um dos lists
        //
        //    L1E = 75    L1D = 51 L2E = 75 L2D = 51  L3E = 75  L3D = 51   
        //    01------------|-------02---------|------03---------|------FIM
        //
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 75 BYTES
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 51 BYTES
       
        //***Este procedimento será utilizado nas outras linhas do g07, mudando apenas o tamanho dos bytes e que os lançamentos serão gravados diretamente
        //**** nos campos MEMOS, pois só irei utiliza-los uma vez 
       
      msgTamSupE   := 77;
      msgTamSupD   := 51;
      msgPosSup    := 7;
      g07Esquerdo  := '';
      g07Direito   := '';
    

       FOR x := 0 to 1 do
         Begin

           //= 3-1 - MENSAGM 1 =

           //LADO ESQUERDO
           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 77 + 7
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));
         
           // POSIÇÃO = 84 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // - 3-1 - FIM -


           //== 3-2 - MENSAGM 2 ==

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 137 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

         
           // POSIÇÃO = 214 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // -- 3-2 - FIM --

           
           //=== 3-3 - MENSAGM 3 ===

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 267 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

           // POSIÇÃO = 7 
           msgPosSup    :=  7;

           // --- 3-3 - FIM ---
     
         End;
     


   
//=== 3 - FIM  ===




//==== 4 - BALANCETE PRINCIPAL ====

      msgTam     := 64;
      msgPos     := 7;
      indiceBal  := 1;


     For x := 0 to (MultLineCount(g07Esquerdo)-1) do
      Begin
        IF(PosStr('>>>', TrimStr(MultLineItem(g07Esquerdo,x))) <> 0) then
         Begin
            INTERNA_SI.REC1.TITULO_BAL := TrimStr(MultLineItem(g07Esquerdo,x));
            g07Esquerdo := MultLineDelete(g07Esquerdo,x);
            break;
         End;
      End;

   
      For x := 2 to 17  do
       Begin

       IF x < 17 THEN
        BEGIN
         //---- 4-1 - MENSAGEM 1  ----

         //LADO ESQUERDO

         INTERNA_SI.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         // POSIÇÃO = 64+7
         msgPos     := msgPos + msgTam ; 
         
         //LADO DIREITO
         INTERNA_SI.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         indiceBal := indiceBal + 1;
         
         // POSIÇÃO = 71+64+2
         msgPos     := msgPos + msgTam + 2;

         //---- 4-1 - FIM ----
         
         //---- 4-2 -  MENSAGEM 2 ----
         
         //LADO ESQUERDO

         INTERNA_SI.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 137 + 64
         msgPos := msgPos + msgTam;         

         //LADO DIREITO
         INTERNA_SI.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
        

          //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         //POSIÇÃO = 201 + 64 +2
         msgPos := msgPos + msgTam + 2;

         indiceBal := indiceBal + 1;
         
         //---- 4-2 - FIM ----
              

         //---- 4-3 - MENSAGEM 3 ----
         
         //LADO ESQUERDO
         INTERNA_SI.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 267 + 64
         msgPos := msgPos + msgTam;

         //LADO DIREITO
         INTERNA_SI.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
          

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         indiceBal := indiceBal + 1; 

         //POSIÇÃO INICIAL
         msgPos := 7;


        //---- 4-3 - FIM ----
 
       End;
   END;    

//==== 4 - FIM ====


//===== 5 - BALANCETE SUPERIOR =====

        //Limitei em 4 linhas, pois o layout do arquivo está diferente do apresentado, então as últimas 2 linhas do g07Esquerdo
        //devem ser apresentadas na taxa condominial

        For x := 0 to 3  do
         Begin
           INTERNA_SI.REC1.BALESUP[x+1] := MultLineItem(g07Esquerdo,x);
         End;

           //Atualizei fora do for para não precisar de um IF dentro do for acima, ganhei uns milisengundos de processamento ...rs
           INTERNA_SI.REC1.BALESUP[1] := TrimStr(MultLineItem(g07Esquerdo,0)) + ' - ' + Global_CNPJ_Benef;


//===== 5 - FIM =====


//====== 6 - COMPOSIÇÃO DA TAXA CONDOMINIAL ======

       indiceTaxaCon := 1;   

       For x := 0 to 5  do
         Begin
          IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
            Begin
              INTERNA_SI.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Direito,x);
              indiceTaxaCon := indiceTaxaCon + 1;
            End;
         End;

        //Só irá lançar caso haja dados além dos 4 default
        IF MultLineCount(g07Esquerdo) > 4 then
        Begin
          for x:= 0 to 1 do
           begin
               if (Length(MultLineItem(g07Esquerdo,x+4))) > 0 then
               begin
                  INTERNA_SI.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Esquerdo,x+4);
                  indiceTaxaCon := indiceTaxaCon + 1;
               end;
           end;
        End;
        
//====== 6 - FIM ======

//======= 7 - INSTRUÇÕES DO BOLETO  =======

      //Nas Instruções utilizarei o g02, onde tem 4 campos de mensagens com tamanho fixo de 80 byte cada

      msgInstrucoesPosInicial := 22;
      msgInstrucoesTamanho    := 80;
      indiceInstrucao := 1;

        For x := 0 to 3  do
         Begin
           
           auxMsgInstrucoes := TrimStr(copy(g02, msgInstrucoesPosInicial, msgInstrucoesTamanho));

           //Só irá gravar caso tenha algo
           IF Length(auxMsgInstrucoes) > 0 THEN
              Begin
                INTERNA_SI.REC1.INSTRUCOES[indiceInstrucao] := auxMsgInstrucoes;
                indiceInstrucao := indiceInstrucao + 1;
              end;
            
           //Atualizo posição inicial para apontar para o próximo campo
           msgInstrucoesPosInicial := msgInstrucoesPosInicial + msgInstrucoesTamanho;            
  
         End;

        For x := 0 to (MultLineCount(g07Direito)-1) do
         Begin
           //Só irá gravar caso tenha algo
           IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
              Begin
                INTERNA_SI.REC1.INSTRUCOES[indiceInstrucao] := MultLineItem(G07Direito,x);
                indiceInstrucao := indiceInstrucao + 1;
              end;           
           End;

//======= 7 - FIM =======


     
          BeginPage(INTERNA_SI);
            WriteRecord(INTERNA_SI,REC1);  
          EndPage(INTERNA_SI);


//== 2 - FIM ==


//======== 8 -  EXTERNA ========

      ClearFields(EXTERNA,REC1);
      EXTERNA.REC1.SEQ         := FormatNumeric(countReg,'#####');
      EXTERNA.REC1.SEQ_2       := countRegTotal;
      EXTERNA.REC1.BENEFICIAR  := Global_Benef; 
      EXTERNA.REC1.NOME        := Global_Nome;
      EXTERNA.REC1.END         := Global_End;
      EXTERNA.REC1.BAIRRO      := Global_Bairro;
      EXTERNA.REC1.CEP         := Global_Cep;
      EXTERNA.REC1.CIDADE      := Global_Cidade;
      EXTERNA.REC1.UF          := Global_Uf;
 

//========= 9 -  MENSAGEM BALANCETE EXTERNO  =========          

      msgTamExterna    := 140;
      msgPosExterna    := 4;
      indiceBalExterna := 1;

      For x := 0 to 11  do
       Begin
         
          EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
         
         // POSIÇÃO = 140 + 4 + 52 (Brancos e Descartaveis)
         msgPosExterna     := msgPosExterna + msgTamExterna + 52; 
         
       
         EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
              
         // POSIÇÃO INICIAL
         msgPosExterna     := 4;

       END;
//======== 9 - FIM ========

       BeginPage(EXTERNA);
       WriteRecord(EXTERNA,REC1);
       EndPage(EXTERNA);

//======= 8 - FIM =======

//========== 10 -  Limpa os  memos ==========

      for x:= 1 to 45 do
      begin
        INTERNA_SI.REC1.LINBAL[x] := '';
        INTERNA_SI.REC1.LINBALD[x] := '';
      end;
       
      for x:= 0 to 5 do
      begin
        INTERNA_SI.REC1.BALESUP[x+1] := '';
      end;

      for x:= 0 to 7 do
      begin
        INTERNA_SI.REC1.TAXACOND[x+1]:= '';
      end;

    for x:= 0 to 9 do
     begin
        INTERNA_SI.REC1.INSTRUCOES[x+1] := '';
     end;
  

    for x:= 0 to 24  do
      begin
        EXTERNA.REC1.LINBALV[x+1] := '';
      end;

//========== 10 - FIM ==========

    END
ELSE

//############################################## BANCO BRADESCO ###########################################
   IF (copy(MultLineItem(g00,0),77,3) = '237') THEN
    BEGIN
 //= 1 - GLOBAIS =


 Global_Nome      := TrimStr(copy(MultLineItem(g01,0),235,40));
 Global_End       := TrimStr(copy(MultLineItem(g01,0),275,40));
 Global_Bairro    := TrimStr(copy(MultLineItem(g01,0),315,12));
 Global_Cep       := copy(MultLineItem(g01,0),327,5) + '-' + copy(MultLineItem(g01,0),332,3);
 Global_Cidade    := TrimStr(copy(MultLineItem(g01,0),335,15));
 Global_Uf        := TrimStr(copy(MultLineItem(g01,0),350,2));
 Global_Benef     := TrimStr(copy(MultLineItem(g07,0),7,77));

 Global_CNPJ_Benef:= FormatCGCCPF(copy(MultLineItem(g00,0),118,14));


//= 1- FIM =
    

//== 2- Gravação de Page Interna ==

     ClearFields(INTERN_BRA,REC1);

     INTERN_BRA.REC1.NOME       := Global_Nome; 
     INTERN_BRA.REC1.END        := Global_End;
     INTERN_BRA.REC1.BAIRRO     := Global_Bairro;
     INTERN_BRA.REC1.CEP        := Global_Cep;
     INTERN_BRA.REC1.CIDADE     := Global_Cidade;
     INTERN_BRA.REC1.UF         := Global_Uf;
    
     // CNPJ OU CPF PAGADOR
     INTERN_BRA.REC1.CNPJ_CPF   := FormatCGCCPF(copy(MultLineItem(g01,0),221,14));

     INTERN_BRA.REC1.BENEFICIAR := Global_Benef + ', ' + Global_CNPJ_Benef;

     INTERN_BRA.REC1.END_BENEF  := TrimStr(copy(MultLineItem(g00,0),132,25)) + ', ' + TrimStr(copy(MultLineItem(g00,0),157,20)) + ' - ' + 
                                   TrimStr(copy(MultLineItem(g00,0),179,12)) + ' - ' + TrimStr(copy(MultLineItem(g00,0),177,2)) +  '- CEP: ' +
                                   TrimStr(copy(MultLineItem(g00,0),191,10));

     // conta benef sem digit
     INTERN_BRA.REC1.CONTABENFE :=  copy(MultLineItem(g01,0),30,7);

     INTERN_BRA.REC1.AGECTACED  := copy(MultLineItem(g01,0),366,4) + ' / ' + copy(MultLineItem(g01,0),30,7) + '-' + copy(MultLineItem(g01,0),37,1) ;
     INTERN_BRA.REC1.ACEITE     := copy(MultLineItem(g01,0),150,1); 


     INTERN_BRA.REC1.DATADOC    := GetDate(MultLineItem(g01,0),151,6);
     INTERN_BRA.REC1.NUMDOC     := TrimStr(copy(MultLineItem(gPRT,(indiceNomeArq-1)),53,25));
     INTERN_BRA.REC1.DATAPROC   := FormatDate(SYS_DATE,'DD/MM/AAAA');

     INTERN_BRA.REC1.BBANCO     := '237';
     INTERN_BRA.REC1.BAGENCIA   := copy(MultLineItem(g01,0),366,6);
     INTERN_BRA.REC1.BVLRTITULO := GetFloat(MultLineItem(g01,0),127,13)/100;
     INTERN_BRA.REC1.BVENC      := GetDate(MultLineItem(g01,0),121,6);
     INTERN_BRA.REC1.BCARTEIRA  := copy(MultLineItem(g01,0),23,2); 
     INTERN_BRA.REC1.BNOSSONUM  := copy(MultLineItem(g01,0),71,11);
     INTERN_BRA.REC1.LOCALPAG   := 'PAGAR PREFERENCIALMENTE NO BANCO BRADESCO';
       
 //=== 3- ARMAZENAMENTO DE 2 LINHAS DO LIST G07 ===
  
        //Armazenarei as 2 primeiras linhas  do g07 em 2 lists, pois irei utilizar em mais de um lugar, terei um acesso mais fácil a eles
        //
        // ---------------------------  ATENÇÃO --------------------------------------------------- 
        //Em uma linha são  6 campos, dividirei em 3 linhas para cada um dos lists
        //
        //    L1E = 75    L1D = 51 L2E = 75 L2D = 51  L3E = 75  L3D = 51   
        //    01------------|-------02---------|------03---------|------FIM
        //
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 75 BYTES
        // LIE = LANÇAMENTO ESQUERDO COM TAMANHO DE 51 BYTES
       
        //***Este procedimento será utilizado nas outras linhas do g07, mudando apenas o tamanho dos bytes e que os lançamentos serão gravados diretamente
        //**** nos campos MEMOS, pois só irei utiliza-los uma vez 
       
      msgTamSupE   := 77;
      msgTamSupD   := 51;
      msgPosSup    := 7;
      g07Esquerdo  := '';
      g07Direito   := '';
    

       FOR x := 0 to 1 do
         Begin

           //= 3-1 - MENSAGM 1 =

           //LADO ESQUERDO
           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 77 + 7
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));
         
           // POSIÇÃO = 84 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // - 3-1 - FIM -


           //== 3-2 - MENSAGM 2 ==

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 137 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

         
           // POSIÇÃO = 214 + 51 + 2 
           msgPosSup    :=  msgPosSup + msgTamSupD + 2;

           // -- 3-2 - FIM --

           
           //=== 3-3 - MENSAGM 3 ===

           //LADO ESQUERDO

           g07Esquerdo   := MultLineAdd(g07Esquerdo,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupE)));

           // POSIÇÃO = 267 + 77
           msgPosSup     := msgPosSup + msgTamSupE; 
         
           //LADO DIREITO
           g07Direito    := MultLineAdd(g07Direito,TrimStr(GetString(MultLineItem(g07, x),msgPosSup,msgTamSupD)));

           // POSIÇÃO = 7 
           msgPosSup    :=  7;

           // --- 3-3 - FIM ---
     
         End;
     


   
//=== 3 - FIM  ===




//==== 4 - BALANCETE PRINCIPAL ====

      msgTam     := 64;
      msgPos     := 7;
      indiceBal  := 1;


     For x := 0 to (MultLineCount(g07Esquerdo)-1) do
      Begin
        IF(PosStr('>>>', TrimStr(MultLineItem(g07Esquerdo,x))) <> 0) then
         Begin
            INTERN_BRA.REC1.TITULO_BAL := TrimStr(MultLineItem(g07Esquerdo,x));
            g07Esquerdo := MultLineDelete(g07Esquerdo,x);
            break;
         End;
      End;

   
      For x := 2 to 17  do
       Begin

       IF x < 17 THEN
        BEGIN
         //---- 4-1 - MENSAGEM 1  ----

         //LADO ESQUERDO

         INTERN_BRA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         // POSIÇÃO = 64+7
         msgPos     := msgPos + msgTam ; 
         
         //LADO DIREITO
         INTERN_BRA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         indiceBal := indiceBal + 1;
         
         // POSIÇÃO = 71+64+2
         msgPos     := msgPos + msgTam + 2;

         //---- 4-1 - FIM ----
         
         //---- 4-2 -  MENSAGEM 2 ----
         
         //LADO ESQUERDO

         INTERN_BRA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 137 + 64
         msgPos := msgPos + msgTam;         

         //LADO DIREITO
         INTERN_BRA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
        

          //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         //POSIÇÃO = 201 + 64 +2
         msgPos := msgPos + msgTam + 2;

         indiceBal := indiceBal + 1;
         
         //---- 4-2 - FIM ----
              

         //---- 4-3 - MENSAGEM 3 ----
         
         //LADO ESQUERDO
         INTERN_BRA.REC1.LINBAL[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
         
         //POSIÇÃO = 267 + 64
         msgPos := msgPos + msgTam;

         //LADO DIREITO
         INTERN_BRA.REC1.LINBALD[indiceBal] := TrimStr(GetString(MultLineItem(g07, x),msgPos,msgTam));
          

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO  -----------

         indiceBal := indiceBal + 1; 

         //POSIÇÃO INICIAL
         msgPos := 7;


        //---- 4-3 - FIM ----
 
       End;
   END;    

//==== 4 - FIM ====


//===== 5 - BALANCETE SUPERIOR =====

        //Limitei em 4 linhas, pois o layout do arquivo está diferente do apresentado, então as últimas 2 linhas do g07Esquerdo
        //devem ser apresentadas na taxa condominial

        For x := 0 to 3  do
         Begin
           INTERN_BRA.REC1.BALESUP[x+1] := MultLineItem(g07Esquerdo,x);
         End;

           //Atualizei fora do for para não precisar de um IF dentro do for acima, ganhei uns milisengundos de processamento ...rs
           INTERN_BRA.REC1.BALESUP[1] := TrimStr(MultLineItem(g07Esquerdo,0)) + ' - ' + Global_CNPJ_Benef;


//===== 5 - FIM =====


//====== 6 - COMPOSIÇÃO DA TAXA CONDOMINIAL ======

       indiceTaxaCon := 1;   

       For x := 0 to 5  do
         Begin
          IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
            Begin
              INTERN_BRA.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Direito,x);
              indiceTaxaCon := indiceTaxaCon + 1;
            End;
         End;

        //Só irá lançar caso haja dados além dos 4 default
        IF MultLineCount(g07Esquerdo) > 4 then
        Begin
          for x:= 0 to 1 do
           begin
               if (Length(MultLineItem(g07Esquerdo,x+4))) > 0 then
               begin
                  INTERN_BRA.REC1.TAXACOND[indiceTaxaCon] := MultLineItem(g07Esquerdo,x+4);
                  indiceTaxaCon := indiceTaxaCon + 1;
               end;
           end;
        End;
        
//====== 6 - FIM ======

//======= 7 - INSTRUÇÕES DO BOLETO  =======


     //Nas Instruções utilizarei o g02, onde tem 4 campos de mensagens com tamanho fixo de 80 byte cada

      msgInstrucoesPosInicial := 2;
      msgInstrucoesTamanho    := 80;
      indiceInstrucao := 1;


       For x := 0 to 3  do
         Begin
           
           auxMsgInstrucoes := TrimStr(copy(g02, msgInstrucoesPosInicial, msgInstrucoesTamanho));

           //Só irá gravar caso tenha algo
           IF Length(auxMsgInstrucoes) > 0 THEN
              Begin
                INTERN_BRA.REC1.INSTRUCOES[indiceInstrucao] := auxMsgInstrucoes;
                indiceInstrucao := indiceInstrucao + 1;
              end;
            
           //Atualizo posição inicial para apontar para o próximo campo
           msgInstrucoesPosInicial := msgInstrucoesPosInicial + msgInstrucoesTamanho;            
  
         End;

        For x := 0 to (MultLineCount(g07Direito)-1) do
         Begin
           //Só irá gravar caso tenha algo
           IF Length(TrimStr(MultLineItem(g07Direito,x))) > 0 THEN
              Begin
                INTERN_BRA.REC1.INSTRUCOES[indiceInstrucao] := MultLineItem(G07Direito,x);
                indiceInstrucao := indiceInstrucao + 1;
              end;           
           End;

//======= 7 - FIM =======


     
          BeginPage(INTERN_BRA);
            WriteRecord(INTERN_BRA,REC1);  
          EndPage(INTERN_BRA);


//== 2 - FIM ==


//======== 8 -  EXTERNA ========

      ClearFields(EXTERNA,REC1);
      EXTERNA.REC1.SEQ         := FormatNumeric(countReg,'#####');
      EXTERNA.REC1.SEQ_2       := countRegTotal;
      EXTERNA.REC1.BENEFICIAR  := Global_Benef; 
      EXTERNA.REC1.NOME        := Global_Nome;
      EXTERNA.REC1.END         := Global_End;
      EXTERNA.REC1.BAIRRO      := Global_Bairro;
      EXTERNA.REC1.CEP         := Global_Cep;
      EXTERNA.REC1.CIDADE      := Global_Cidade;
      EXTERNA.REC1.UF          := Global_Uf;
 

//========= 9 -  MENSAGEM BALANCETE EXTERNO  =========          

      msgTamExterna    := 140;
      msgPosExterna    := 4;
      indiceBalExterna := 1;

      For x := 0 to 11  do
       Begin
         
          EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
         
         // POSIÇÃO = 140 + 4 + 52 (Brancos e Descartaveis)
         msgPosExterna     := msgPosExterna + msgTamExterna + 52; 
         
       
         EXTERNA.REC1.LINBALV[indiceBalExterna] := GetString(MultLineItem(g08, x),msgPosExterna,msgTamExterna);

         
         //--------- PULAR UMA LINHA E ATUALIZAR POSIÇÃO
         
         indiceBalExterna := indiceBalExterna + 1;
              
         // POSIÇÃO INICIAL
         msgPosExterna     := 4;

       END;
//======== 9 - FIM ========

       BeginPage(EXTERNA);
       WriteRecord(EXTERNA,REC1);
       EndPage(EXTERNA);

//======= 8 - FIM =======




//========== 10 -  Limpa os  memos ==========

      for x:= 1 to 45 do
      begin
        INTERN_BRA.REC1.LINBAL[x] := '';
        INTERN_BRA.REC1.LINBALD[x] := '';
      end;
       
      for x:= 0 to 5 do
      begin
        INTERN_BRA.REC1.BALESUP[x+1] := '';
      end;

      for x:= 0 to 7 do
      begin
        INTERN_BRA.REC1.TAXACOND[x+1]:= '';
      end;

    for x:= 0 to 9 do
     begin
        INTERN_BRA.REC1.INSTRUCOES[x+1] := '';
     end;
  

    for x:= 0 to 24  do
      begin
        EXTERNA.REC1.LINBALV[x+1] := '';
      end;

//========== 10 - FIM ==========

END;

//------------ LIMPANDO OS GRUPOS E DELIMITADOR DE REGISTRO -------------------------------

      sGrupo_Old := '';
      g01 := MultLineClear(g01);
      G02 := '';
      g06 := '';
      g07 := MultLineClear(g07);
      g08 := MultLineClear(g08);
      g07Esquerdo  := MultLineClear(g07Esquerdo);
      g07Direito   := MultLineClear(g07Direito);

//---------------------------------- FIM DE LIMPEZA ----------------------------------------

End;

//---------------------------------- FIM DE GRAVAÇÃO ---------------------------------------

//---------------------------------- CAPTURA DOS DADOS  -------------------------------------
     
  // Grupo 00 - HEADER
  If GetString(S,1,3) = 'PRT' then  
  begin
    gPRT := MultLineAdd(gPRT,S); 
  end;

  // Grupo 00 - HEADER
  If GetString(S,1,1) = '0' then  
  begin
    countReg := 0;
    indiceNomeArq := indiceNomeArq + 1;

    g00 := MultLineAdd(g00,S); 
  end;

  //DADOS DO BENEFICIÁRIO E PAGADOR
  If GetString(S,1,1) = '1' then  
  begin
    g01 := MultLineAdd(g01,S); 
  end;

  //INSTRUCOES DO BOLETO --  (PARA ARQUIVOS SICREDI E BRADESCO ) 
  If GetString(S,1,1) = '2' then  
  begin
    g02 := S; 
  end;

  //INSTRUCOES DO BOLETO --  ( APENAS PARA ARQUIVOS ITAU ) 
  If GetString(S,1,1) = '6' then  
  begin
    g06 := S; 
  end;

  //BALANCETE INTERNO
  If GetString(S,1,1) = '7' then  
  begin
    g07 := MultLineAdd(g07,S); 
  end;

  //BALANCETE EXTERNO
  If GetString(S,1,1) = '8' then  
  begin
    g08 := MultLineAdd(g08,S); 
    sGrupo_old := '8';
  end;

  if GetString(S,1,1) = '9' then
  begin
       g00 := MultLineClear(g00);
  end;

//-------------------------------------- FIM CAPTURA DOS DADOS -------------------------------

  if LeLinha = EOF then break;
End;
