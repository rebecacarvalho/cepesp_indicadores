README
================
Rebeca Carvalho
11 de julho de 2019

Responsáveis
------------

-   Gabriela Soares Campos

-   Rebeca Carvalho

Funcionamento
-------------

1.  Para verificar o processamento dos dados utilizados no app, assim como o cálculo dos indicadores, basta rodar o script `00_index.R`.

2.  Para acesssar o aplicativo de indicadores, basta rodar o script `global.R`.

Divisão dos *scripts*
---------------------

### Dos dados:

-   vagas.R: faz o download dos dados (TSE) referentes as vagas dos cargos estaduais e municipais.

-   00\_index.R: *script* sumário, responsável por criar os bancos de indicadores.

-   01\_join.R: junta os dados do CepespR com os arquivos de vagas.

-   02\_calcdistribuicao.R: calcula os indicadores de distribuição de cadeiras.

-   03\_calcfragmentacao.R: calcula os indicadores de fragmentação partidária.

-   04\_calcrenovacao.R: calcula os indicadores de renovação das bancadas.

-   05\_calcalienacao.R: calcula os indicadores de alienação.

### Do aplicativo:

-   global.R: *script* sumário do aplicativo, responsável por carregar os indicadores pré-calculados e rodar as demais partes do app.

-   ui.R: *script* referente a interface do usuário do aplicativo.

-   server.R: *script* referente as configurações do servidor do aplicativo.
