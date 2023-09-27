#Include 'TOTVS.CH'

/*/{Protheus.doc} User Function fMbroPed
    Funcao utilizada para montar a tela padrao da mbrowse Modelo 2, onde traz a tela de cadastro de Pedidos de Compra 
	com uma 1 só tabela separada em cabeçalho e grid ,onde as chaves se repetem para todos os itens – C7_FILIAL + C7_NUM)
    @type  Function
    @author Scheron Martins
    @since 27/09/2023
    @version 1.0
    @param Nenhum
    @return Vazio (nil)
    @example Exemplo da utilizacao do Modelo 2
        @see : MBrowse               https://tdn.totvs.com/pages/releaseview.action?pageId=24346981
               Banco de Dados        https://tdn.totvs.com/display/tec/Banco+de+Dados
/*/

User Function fMbroPed()
PRIVATE cCadastro := "Pedidos de Compra"
PRIVATE cAlias1   := "SC7"
PRIVATE aRotina   := {}

aAdd(aRotina,{"Visualizar"	,"U_Model2('VISUALIZAR')",0,2})
aAdd(aRotina,{"Incluir"		,"U_Model2('INCLUIR')"	 ,0,3})
aAdd(aRotina,{"Alterar"		,"U_Model2('ALTERAR')"	 ,0,4})
aAdd(aRotina,{"Excluir"		,"U_Model2('EXCLUIR')"	 ,0,5})

mBrowse(/*nLinha1*/,/*nColuna1*/,/*nLinha2*/,/*nColuna2*/,cAlias1)

Return

User Function Model2(cOpcao)
Local na, _ni, _nd, _na
Local aObjects := {}
Local _sAlias  := Alias()
Local nRegistro:= SC7->( RECNO() )
Local aReg     := {}
Local nOpcx

Private aCols  := {} 
Private cNum   := SC7->C7_NUM

//	nOpcx => 3=Incluir , 4=Alterar, 5=Excluir

Do CASE
    Case cOpcao == 'INCLUIR'
        nOpcx := 3
    Case cOpcao == 'VISUALIZAR'
        nOpcx := 1
    Case cOpcao == 'ALTERAR'
        nOpcx := 4
    Case cOpcao == 'EXCLUIR'
        nOpcx := 5
	Otherwise
		Return
EndCase

nUsado  := 0
//Cria os campos da tabela 
dBSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias1)
aHeader := {}
While (x3_arquivo == cAlias1)
    If X3USO(x3_usado) .AND. cNivel >= x3_nivel
        nUsado ++
        aAdd(aHeader,{	TRIM(x3_titulo),;
						x3_campo,		;
						x3_picture,		;
						x3_tamanho,		;
						x3_decimal,		;
						"ExecBlock('Md2Valid',.F.,.F.)",;
						x3_usado,		;
						x3_tipo,		; 
						x3_arquivo,		;
						x3_context})
    EndIf
    dbSkip()
End
//nao sei
If nOpcx <> 3
    DbSelectArea(cAlias1)
    DbSetOrder(1)
    dbSeek( xFilial("SC7") + cNum )
    Do While .not. SC7->( Eof() ) .AND. C7_FILIAL + C7_NUM == xFilial("SC7") + cNum
        aAdd(aReg, SC7->( RecNo() ))
        aAdd(aCols, Array( Len( aHeader ) + 1))
        For _nd := 1 To Len( aHeader )
            aCols[Len(aCols),_nd] := FieldGet(FieldPos(aHeader[_nd,2]))
        Next _nd
//		aCols terá sempre uma coluna a mais que o aHeader para armazenar se o registro está deletado
		aCols[Len(aCols)][nUsado + 1] := .F.
        SC7->( dbSkip() )
    Enddo    
Else
    dBSelectArea("SX3")
    dbSetOrder(1)
    dbSeek(cAlias1)
    aCols	:= Array(1,nUsado + 1)
    nUsado	:= 0
    Do While ! EOF() .and. (x3_arquivo == cAlias1)
        If X3USO(x3_usado) .AND. cNivel >= x3_nivel
            nUsado++
            If nOpcx == 3
                If x3_tipo == "C"
                    aCols[1][nUsado] := Space(x3_tamanho)
                ElseIf x3_tipo == "N"
                    aCols[1][nUsado] := 0
                ElseIf x3_tipo == "D"
                    aCols[1][nUsado] := dDataBase
                ElseIf x3_tipo == "M"
                    aCols[1][nUsado] := ""
                Else
                    aCols[1][nUsado] := .F.
                EndIf
            EndIf
        EndIf
        dbSkip()
//		aCols terá sempre uma coluna a mais que o aHeader para armazenar se o registro está deletado
		aCols[1][nUsado + 1] := .F.
    Enddo
EndIf

DbSelectArea("SC7")
DbSetOrder(1)
SC7->( dbGoto( nRegistro ) )

If nOpcx <> 3
    nNumero		:= SC7->C7_NUM   
    dData		:= SC7->C7_EMISSAO
    cFornecedo	:= SC7->C7_FORNECE
    cLoja		:= SC7->C7_LOJA  
    cPagamento	:= SC7->C7_COND  
    cContato	:= SC7->C7_CONTATO
    cFilialEnt	:= SC7->C7_FILENT
    cMoeda		:= SC7->C7_MOEDA 
    cTxMoeda	:= SC7->C7_TXMOEDA

Else
    nNumero		:= GetSXEnum("SC7","C7_NUM")
    dData		:= Date()
    cFornecedo	:= Space(06)
    cLoja		:= Space(02)
    cPagamento	:= Space(01)
    cContato	:= Space(11)
    cFilialEnt	:= SC7->C7_FILENT
    cMoeda		:= SC7->C7_MOEDA
    cTxMoeda	:= Space(5)
EndIf

aC := {}
aAdd(aC,{"nNumero"		,{15, 10},"Numero"		,"@!"		,,		,.F.})
aAdd(aC,{"dData"		,{15,150},"Dt.Emissao"	,	 		,,		,.F.})
aAdd(aC,{"cFornecedo"	,{15,350},"Fornecedor"	,	 		,,"SA2"	,.F.})
aAdd(aC,{"cLoja"		,{15,480},"Loja"		,	 		,,		,.F.})
aAdd(aC,{"cPagamento"	,{27, 10},"Cond.Pagto."	,	 		,,"SE4"	,.F.})
aAdd(aC,{"cContato"		,{27,150},"Contato."	,	 		,,		,.F.})
aAdd(aC,{"cFilialEnt"	,{27,350},"Fil.Entrega"	,	 		,,		,.F.})
aAdd(aC,{"cMoeda"		,{39, 10},"Moeda"		,"@!"		,,"SM2"	,.F.})
aAdd(aC,{"cTxMoeda"		,{39,150},"Taxa"		,"@E 9,9999",,		,.F.})

cValor	:= SC7->C7_TOTAL
cFrete	:= Space(6)

nLinGetD:= 0

aR		:= {}

aAdd(aR,{"cValor", {120,10},"Valor da Mercadoria","@E 999.999,99",,,.F.})
aAdd(aR,{"cFrete", {136,10},"Frete","@E 999.999,99",,,.F.})

aCGD 	:= {110,70,118,315}

aSize 	:= MsAdvSize()
aAdd(aObjects, {100, 80, .T., .F.})
aAdd(aObjects, {100, 360, .T., .T.})

aInfo	:= {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aTela	:= {aSize[7],0,aSize[6],aSize[5]}

cLinhaOk:= "AllwaysTrue()"
cTudoOk := "ExecBlock('Md2TudOk',.f.,.f.)"

lRet	:= Modelo2(cCadastro,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,aTela)

// A variavel lRet será verdadeira caso o usuario clique no botão "Confirma"
If lRet 
	IF nOpcx == 3
		DbSelectArea("SC7")
		DbSetOrder(1)
		For _ni := 1 to Len(aCols)
			If !aCols[_ni,Len(aCols[_ni])]
				RecLock("SC7", .T.)
				For na := 1 to Len(aHeader)
					FieldPut(FieldPos(Trim(aHeader[na, 2])), aCols[_ni,na])
				Next
				SC7->C7_FILIAL  := xFilial("SC7")
				SC7->C7_NUM     := nNumero
				SC7->C7_EMISSAO := dData
				SC7->C7_FORNECE := cFornecedo
				SC7->C7_LOJA    := cLoja
				SC7->C7_COND    := cPagamento
				SC7->C7_CONTATO := cContato  
				SC7->C7_FILENT  := cFilialEnt
				SC7->C7_MOEDA   := cMoeda
				SC7->C7_TIPO    := 1
				MsUnlock()
				If _ni == 1
					nRegistro:= SC7->( RECNO() )
				EndIf
			EndIf
		Next
		ConfirmSx8()
	ElseIf nOpcx == 4
		DbSelectArea("SC7")
		DbSetOrder(1)
		For _na := 1 to Len(aCols)
			If _na <= Len( aReg )
				DbGoTo(aReg[_na])
				RecLock("SC7", .F.)
				If aCols[_na, Len( aHeader ) + 1]
					DbDelete()
				EndIf
			Else 
				If !aCols[_na, Len( aHeader) + 1]
					RecLock("SC7", .F.)
				EndIf
			EndIf
			If !aCols[_na, Len( aHeader ) + 1]
				For na := 1 to Len( aHeader )
					FieldPut(FieldPos(Trim(aHeader[na, 2])), aCols[_na,na])
				Next
			EndIf
			MsUnlock()
		Next
		ConfirmSx8()
	ElseIf nOpcx == 5
		DbSelectArea("SC7")
		DbSetOrder(1)
		dbSeek(xFilial("SC7") + cNUM )
		if SC7->(C7_FILIAL + C7_NUM) == xFilial("SC7") + cNUM
			RecLock("SC7",.F.)
			SC7->( DbDelete() )
			SC7->( MsUnlock() )
		endif
		SC7->( dbSkip() )
	EndIf
Endif

dbSelectArea(_sAlias)
dbGoto(nRegistro)

Return

User Function MD2TudOk()

Return .t.

User Function Md2Valid()

Return .t.
