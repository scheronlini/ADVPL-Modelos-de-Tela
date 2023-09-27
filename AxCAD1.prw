#Include 'TOTVS.CH'

/*/{Protheus.doc} User Function fAxCadas
    Funcao utilizada para montar a tela padrao da axCadastro (modelo 1).
    @type  Function
    @author Scheron Martins
    @since 27/09/2023
    @version 1.0
    @param Nenhum
    @return Vazio (nil)
    @example Exemplo da utilizacao da Tela AXCadastro
        @see : AxCadastro https://tdn.totvs.com/display/public/framework/AxCadastro
/*/
User Function fAxCadas()

AxCadastro("SA1", "Cadastro de Clientes")  

Return(.T.)                        
