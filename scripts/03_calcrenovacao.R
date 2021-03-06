
# Pacotes utilizados

library(cepespR)
library(dplyr)
library(tidyverse)
library(abjutils)

# Objetivo
#'        - Calcular os indicadores de renovacao das bancadas:
#'        - Conservacao, Renovacao bruta, Renovacao liquida;
#'        - Limpeza e padronizacao dos dados.



# 1. Formulas -------------------------------------------------------------

## Formula para o calculo da conservacao parlamentar

conserv <- function(reel, derr) {
  reel/(derr + reel) * 100
}

## Funcao para o calculo da renovacao bruta

renov_br <- function(desi,derr, vag){
  (desi + derr)/(vag)*100
}

## Funcao para o calculo da renovacao liquida

renov_liq <- function(derr, reel){
  derr/(reel + derr)*100
}


# 2. Calculo dos indicadores ----------------------------------------------------------

## Descarta as colunas desnecessarias

### Deputado Federal

df <- df %>% 
  select(ANO_ELEICAO, 
         UF,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)%>% 
  mutate_all(na_if,"")

### Deputado Estadual

de <- de %>% 
  select(ANO_ELEICAO, 
         UF,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)%>% 
  mutate_all(na_if,"")

### Vereador

vr <- vr %>% 
  select(ANO_ELEICAO, 
         UF,
         COD_MUN_TSE,
         NOME_MUNICIPIO,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)%>% 
  mutate_all(na_if,"")

## Transforma as observacoes vazias em NA

### Deputado Federal

df[df ==""]<-NA

### Deputado Estadual

de[de ==""]<-NA

### Vereador

vr[vr ==""]<-NA

## Omite os valores NA

### Deputado Federal

df <- na.omit(df) 

### Deputado Estadual

de2 <- de1

de2 <- de2 %>% 
  select(`Ano da eleição`,
         UF,
         Vagas)

de2 <- unique(de2)

de <- na.omit(de) 

### Vereador

vr <- na.omit(vr) 


## Cria um banco com somente os candidatos eleitos em cada eleicao

### Deputado Federal

cand_df <- df %>% 
  filter(DESC_SIT_TOT_TURNO == "ELEITO"|
         DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
         DESC_SIT_TOT_TURNO == "ELEITO POR QP"
           ) %>%
  select(ANO_ELEICAO, 
         UF,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)

### Deputado Estadual

cand_de <- de %>% 
  filter(DESC_SIT_TOT_TURNO == "ELEITO"|
           DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
           DESC_SIT_TOT_TURNO == "ELEITO POR QP"
  ) %>%
  select(ANO_ELEICAO, 
         UF,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)

### Vereador

cand_vr <- vr %>% 
  filter(DESC_SIT_TOT_TURNO == "ELEITO"|
           DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
           DESC_SIT_TOT_TURNO == "ELEITO POR QP"
  ) %>%
  select(ANO_ELEICAO, 
         UF,
         COD_MUN_TSE,
         NOME_MUNICIPIO,
         DESCRICAO_CARGO,
         NOME_CANDIDATO,
         DATA_NASCIMENTO,
         CPF_CANDIDATO,
         NUM_TITULO_ELEITORAL_CANDIDATO,
         SIGLA_PARTIDO,
         DESC_SIT_TOT_TURNO)

## For loop que calcula os indicadores de renovacao parlamentar

### Deputado Federal (Brasil)

ind_eleicoes_fed_br <- list()


for(ano in sort(unique(df$ANO_ELEICAO))){
  cat("Lendo",ano,"\n")
  
## Banco com os candidatos da proxima eleicao
  
  candidatos_ano2 <- filter(df,
                       ANO_ELEICAO == ano + 4)
## Bancos com os candidatos eleitos na primeira e
## segunda eleicao de referencia
  
  eleitos_ano1 <- filter(cand_df,
                  ANO_ELEICAO == ano)
  eleitos_ano2 <- filter(df,
                 ANO_ELEICAO == ano+4)
## Filtra os candidatos que se reapresentaram na eleicao
## seguinte e os que foram reeleitos
  
  eleitos_ano2 <- filter(eleitos_ano2, NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                          eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO)
  indicadores1 <- filter(candidatos_ano2,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in%
                         eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO) %>% 
                  summarise(
                          `Reapresentação` = n()
                  )
  
## Dos candidatos que se reapresentaram na eleicao seguinte a
## eleicao de referencia, filtra-se somente os eleitos
  
  indicadores1$`Ano da eleição` <- ano + 4
  indicadores2 <- eleitos_ano2 %>% 
    filter(DESC_SIT_TOT_TURNO == "ELEITO"|
           DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
           DESC_SIT_TOT_TURNO == "ELEITO POR QP") %>% 
    summarise(
      Reeleitos = n()
    )

## Remove os bancos que nao serao mais utilizados
  
  rm(eleitos_ano1,eleitos_ano2)
  
## Filtra nos bancos referentes as estatiscas gerais das
## eleicoes, somente os anos que estao sendo 
## utilizados no momento  
  estatisticas_ano1 <- filter(df1_br,
                            `Ano da eleição` == ano)
  estatisticas_ano2 <- filter(df1_br,
                            `Ano da eleição` == ano + 4)
  
## Acrescenta as colunas `Ano de eleição` bancos gerados
    
  indicadores1$`Ano da eleição` <- ano + 4
  indicadores2$`Ano da eleição` <- ano + 4

## Junta os bancos em um unico  
  
  indicadores1 <- left_join(indicadores1,
                            indicadores2, 
                            by = "Ano da eleição")
  
## Calculo dos indicadores de renovacao parlamentar  
  
  indicadores1$Derrotados <- indicadores1$Reapresentação - indicadores1$Reeleitos
  indicadores1$Desistência <- 513 - indicadores1$Reapresentação
  if(indicadores1$Reapresentação > 0){
  indicadores1$`Conservação` <- conserv(indicadores1$Reeleitos, 
                                        indicadores1$Derrotados)
  indicadores1$`Renovação bruta` <- renov_br(indicadores1$Desistência,
                                             indicadores1$Derrotados, 513)
  indicadores1$`Renovação líquida` <- renov_liq(indicadores1$Derrotados, 
                                          indicadores1$Reeleitos)
  }

  ## Empilha todas as eleicoes 
  
  ind_eleicoes_fed_br <- bind_rows(ind_eleicoes_fed_br,indicadores1)
}

## Remove as linhas desnecessarias

ind_eleicoes_fed_br <- ind_eleicoes_fed_br[-c(6),]

ind_eleicoes_fed_br$Cargo <- "Deputado Federal"

## Reorganiza a tabela

ind_eleicoes_fed_br$`Cadeiras disponíveis` <- 513

ind_eleicoes_fed_br <- ind_eleicoes_fed_br %>% 
  select(`Ano da eleição`,
         Cargo,
         `Cadeiras disponíveis`,
         Reapresentação,
         Reeleitos,
         Conservação,
         `Renovação bruta`,
         `Renovação líquida`)

### Deputado Federal (UF)


ind_eleicoes_fed_uf <- list()


for(ano in sort(unique(df$ANO_ELEICAO))){
  for(uf in sort(unique(df$UF))){
  cat("Lendo",ano,uf,"\n")
  
  ## Banco com os candidatos da proxima eleicao
  
  candidatos_ano2 <- filter(df,
                            ANO_ELEICAO == ano + 4,
                            UF == uf)
  ## Bancos com os candidatos eleitos na primeira e
  ## segunda eleicao de referencia
  
  eleitos_ano1 <- filter(cand_df,
                         ANO_ELEICAO == ano,
                         UF == uf)
  eleitos_ano2 <- filter(df,
                         ANO_ELEICAO == ano+4,
                         UF == uf)
  ## Filtra os candidatos que se reapresentaram na eleicao
  ## seguinte e os que foram reeleitos
  
  eleitos_ano2 <- filter(eleitos_ano2, NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                           eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO)
  indicadores1 <- filter(candidatos_ano2,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in%
                           eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO) %>% 
    summarise(
      `Reapresentação` = n()
    )
  
  ## Dos candidatos que se reapresentaram na eleicao seguinte a
  ## eleicao de referencia, filtra-se somente os eleitos
  
  indicadores1$`Ano da eleição` <- ano + 4
  indicadores1$UF <- uf
  indicadores2 <- eleitos_ano2 %>% 
    filter(DESC_SIT_TOT_TURNO == "ELEITO"|
             DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
             DESC_SIT_TOT_TURNO == "ELEITO POR QP") %>% 
    summarise(
      Reeleitos = n()
    )
  
  ## Remove os bancos que nao serao mais utilizados
  
  rm(eleitos_ano1,eleitos_ano2)
  
  ## Filtra nos bancos referentes as estatiscas gerais das
  ## eleicoes, somente os anos que estao sendo 
  ## utilizados no momento  
  estatisticas_ano1 <- filter(df1_uf,
                              `Ano da eleição` == ano,
                              UF == uf)
  estatisticas_ano2 <- filter(df1_uf,
                              `Ano da eleição` == ano + 4,
                              UF == uf)
  
  ## Acrescenta as colunas `Ano de eleição` bancos gerados
  
  indicadores1$`Ano da eleição` <- ano + 4
  indicadores1$UF <- uf
  indicadores2$`Ano da eleição` <- ano + 4
  indicadores2$UF <- uf
  
  ## Junta os bancos em um unico  
  
  indicadores1 <- left_join(indicadores1,
                            indicadores2, 
                            by = c("Ano da eleição",
                                   "UF"))
  
  ## Calculo dos indicadores de renovacao parlamentar  
  
  indicadores1$Derrotados <- indicadores1$Reapresentação - indicadores1$Reeleitos
  indicadores1$Desistência <- unique(estatisticas_ano1$Vagas) - indicadores1$Reapresentação
  if(indicadores1$Reapresentação > 0){
    indicadores1$`Conservação` <- conserv(indicadores1$Reeleitos, 
                                          indicadores1$Derrotados)
    indicadores1$`Renovação bruta` <- renov_br(indicadores1$Desistência,
                                               indicadores1$Derrotados, 
                                               unique(estatisticas_ano1$Vagas))
    indicadores1$`Renovação líquida` <- renov_liq(indicadores1$Derrotados, 
                                                  indicadores1$Reeleitos)
  }
  ## Empilha todas as eleicoes 
  
  ind_eleicoes_fed_uf <- bind_rows(ind_eleicoes_fed_uf,indicadores1)
  }
}


## Remove as linhas desnecessarias

ind_eleicoes_fed_uf <- ind_eleicoes_fed_uf[-c(136:162),]

ind_eleicoes_fed_uf$Cargo <- "Deputado Federal"

vagas <- df1_uf %>% 
  select(`Ano da eleição`, 
         UF, 
         Vagas) %>% 
  unique()

ind_eleicoes_fed_uf <- left_join(ind_eleicoes_fed_uf, vagas, 
                                 by = c("Ano da eleição",
                                        "UF"))


## Reorganiza a tabela

ind_eleicoes_fed_uf <- ind_eleicoes_fed_uf %>% 
  select(`Ano da eleição`,
         UF,
         Cargo,
         Vagas,
         Reapresentação,
         Reeleitos,
         Conservação,
         `Renovação bruta`,
         `Renovação líquida`) %>% 
  dplyr::rename("Cadeiras disponíveis" = "Vagas")

### Deputado Estadual (Brasil)


ind_eleicoes_est <- list()

for(ano in sort(unique(de$ANO_ELEICAO))){
  for(uf in sort(unique(de$UF))){
    cat("Lendo",ano,uf,"\n")
    
    ## Banco com os candidatos da proxima eleicao
    
    candidatos <- filter(de,
                         ANO_ELEICAO == ano + 4,
                         UF == uf)
    ## Bancos com os candidatos eleitos na primeira e
    ## segunda eleicao de referencia
    
    eleitos_ano1 <- filter(cand_de,
                           ANO_ELEICAO == ano,
                           UF == uf)
    eleitos_ano2 <- filter(cand_de,
                           ANO_ELEICAO == ano+4,
                           UF == uf)
    ## Filtra os candidatos que se reapresentaram na eleicao
    ## seguinte e os que foram reeleitos
    ## OBS: O estado do Rio de Janeiro possui dados incompletos
    ## e, por isso, foi necessario um tratamento especifico para ele
    
    if(uf =="RJ" & ano == 1998){
      eleitos_ano2 <- filter(eleitos_ano2,
                             NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                               eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO &
                               DATA_NASCIMENTO %in% eleitos_ano1$DATA_NASCIMENTO)
      indicadores1 <- filter(candidatos,
                             NUM_TITULO_ELEITORAL_CANDIDATO %in%
                               eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO &
                               DATA_NASCIMENTO %in% eleitos_ano1$DATA_NASCIMENTO) %>% 
        summarise(
          `Reapresentação` = n())
    }else {
      eleitos_ano2 <- filter(eleitos_ano2,
                             NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                               eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO)
      indicadores1 <- filter(candidatos,
                             NUM_TITULO_ELEITORAL_CANDIDATO %in%
                               eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO) %>% 
        summarise(
          `Reapresentação` = n())
    }
    
    ## Dos candidatos que se reapresentaram na eleicao seguinte a
    ## eleicao de referencia, filtra-se somente os eleitos
    
    indicadores2 <- eleitos_ano2 %>% 
      filter(DESC_SIT_TOT_TURNO == "ELEITO"|
               DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
               DESC_SIT_TOT_TURNO == "ELEITO POR QP") %>% 
      summarise(
        Reeleitos = n()
      )
    ## Remove os bancos que nao serao mais utilizados
    
    rm(eleitos_ano1,eleitos_ano2)
    
    ## Filtra nos bancos referentes as estatiscas gerais das
    ## eleicoes, somente os anos e uf's que estao sendo 
    ## utilizados no momento
    
    estatisticas_ano1 <- filter(de1,
                                `Ano da eleição` == ano,
                                UF == uf)
    estatisticas_ano2 <- filter(de1,
                                `Ano da eleição` == ano+4,
                                UF == uf)
    ## Acrescenta as colunas `Ano de eleição` e UF aos bancos gerados
    
    indicadores1$`Ano da eleição` <- ano + 4
    indicadores1$UF <- uf
    indicadores2$`Ano da eleição` <- ano + 4
    indicadores2$UF <- uf
    
    ## Junta os bancos em um unico  
    
    indicadores1 <- left_join(indicadores1,
                              indicadores2, 
                              by = c("Ano da eleição",
                                     "UF"))
    
    indicadores1 <- left_join(indicadores1,de2, by = c("Ano da eleição",
                                                       "UF"))
    
    ## Calculo dos indicadores de renovacao parlamentar
    
    indicadores1$Derrotados <- indicadores1$Reapresentação - indicadores1$Reeleitos
    indicadores1$Desistência <- unique(estatisticas_ano1$Vagas) - indicadores1$Reapresentação
    if(indicadores1$Reapresentação > 0){
      indicadores1$`Conservação` <- conserv(indicadores1$Reeleitos, 
                                            indicadores1$Derrotados)
      indicadores1$`Renovação bruta` <- renov_br(indicadores1$Desistência,
                                                 indicadores1$Derrotados, 
                                                 indicadores1$Vagas)
      indicadores1$`Renovação líquida` <- renov_liq(indicadores1$Derrotados, 
                                                    indicadores1$Reeleitos)
    }
    
    ## Empilha todas as ufs e eleicoes 
    
    ind_eleicoes_est <- bind_rows(ind_eleicoes_est,indicadores1)
  }
}

## Remove as linhas desnecessarias

ind_eleicoes_est <- ind_eleicoes_est[-c(136:162),]

## Reorganiza a tabela

ind_eleicoes_est$Cargo <- "Deputado Estadual"

ind_eleicoes_est <- ind_eleicoes_est %>% 
  select(`Ano da eleição`,
         UF,
         Cargo,
         Vagas,
         Reapresentação,
         Reeleitos,
         Conservação,
         `Renovação bruta`,
         `Renovação líquida`) %>% 
  rename("Cadeiras disponíveis" = "Vagas")


### Deputado Estadual (UF)



ind_eleicoes_est <- list()

for(ano in sort(unique(de$ANO_ELEICAO))){
  for(uf in sort(unique(de$UF))){
  cat("Lendo",ano,uf,"\n")
    
## Banco com os candidatos da proxima eleicao
    
  candidatos <- filter(de,
                       ANO_ELEICAO == ano + 4,
                       UF == uf)
## Bancos com os candidatos eleitos na primeira e
## segunda eleicao de referencia
  
  eleitos_ano1 <- filter(cand_de,
                 ANO_ELEICAO == ano,
                 UF == uf)
  eleitos_ano2 <- filter(cand_de,
                 ANO_ELEICAO == ano+4,
                 UF == uf)
## Filtra os candidatos que se reapresentaram na eleicao
## seguinte e os que foram reeleitos
## OBS: O estado do Rio de Janeiro possui dados incompletos
## e, por isso, foi necessario um tratamento especifico para ele
  
  if(uf =="RJ" & ano == 1998){
  eleitos_ano2 <- filter(eleitos_ano2,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                         eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO &
                         DATA_NASCIMENTO %in% eleitos_ano1$DATA_NASCIMENTO)
  indicadores1 <- filter(candidatos,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in%
                         eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO &
                         DATA_NASCIMENTO %in% eleitos_ano1$DATA_NASCIMENTO) %>% 
                  summarise(
                         `Reapresentação` = n())
  }else {
  eleitos_ano2 <- filter(eleitos_ano2,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                         eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO)
  indicadores1 <- filter(candidatos,
                         NUM_TITULO_ELEITORAL_CANDIDATO %in%
                         eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO) %>% 
                  summarise(
                         `Reapresentação` = n())
        }

## Dos candidatos que se reapresentaram na eleicao seguinte a
## eleicao de referencia, filtra-se somente os eleitos
  
  indicadores2 <- eleitos_ano2 %>% 
    filter(DESC_SIT_TOT_TURNO == "ELEITO"|
           DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
           DESC_SIT_TOT_TURNO == "ELEITO POR QP") %>% 
    summarise(
      Reeleitos = n()
    )
## Remove os bancos que nao serao mais utilizados
  
  rm(eleitos_ano1,eleitos_ano2)
  
## Filtra nos bancos referentes as estatiscas gerais das
## eleicoes, somente os anos e uf's que estao sendo 
## utilizados no momento
  
  estatisticas_ano1 <- filter(de1,
                 `Ano da eleição` == ano,
                 UF == uf)
  estatisticas_ano2 <- filter(de1,
                 `Ano da eleição` == ano+4,
                 UF == uf)
## Acrescenta as colunas `Ano de eleição` e UF aos bancos gerados
  
  indicadores1$`Ano da eleição` <- ano + 4
  indicadores1$UF <- uf
  indicadores2$`Ano da eleição` <- ano + 4
  indicadores2$UF <- uf

## Junta os bancos em um unico  
    
  indicadores1 <- left_join(indicadores1,
                            indicadores2, 
                            by = c("Ano da eleição",
                                   "UF"))
  
 indicadores1 <- left_join(indicadores1,de2, by = c("Ano da eleição",
                                                    "UF"))
  
## Calculo dos indicadores de renovacao parlamentar
  
  indicadores1$Derrotados <- indicadores1$Reapresentação - indicadores1$Reeleitos
  indicadores1$Desistência <- unique(estatisticas_ano1$Vagas) - indicadores1$Reapresentação
  if(indicadores1$Reapresentação > 0){
  indicadores1$`Conservação` <- conserv(indicadores1$Reeleitos, 
                                        indicadores1$Derrotados)
  indicadores1$`Renovação bruta` <- renov_br(indicadores1$Desistência,
                                             indicadores1$Derrotados, 
                                             indicadores1$Vagas)
  indicadores1$`Renovação líquida` <- renov_liq(indicadores1$Derrotados, 
                                                indicadores1$Reeleitos)
  }
  
## Empilha todas as ufs e eleicoes 
  
  ind_eleicoes_est <- bind_rows(ind_eleicoes_est,indicadores1)
  }
}

## Remove as linhas desnecessarias

ind_eleicoes_est <- ind_eleicoes_est[-c(136:162),]

## Reorganiza a tabela

ind_eleicoes_est$Cargo <- "Deputado Estadual"

ind_eleicoes_est <- ind_eleicoes_est %>% 
  select(`Ano da eleição`,
         UF,
         Cargo,
         Vagas,
         Reapresentação,
         Reeleitos,
         Conservação,
         `Renovação bruta`,
         `Renovação líquida`) %>% 
  rename("Cadeiras disponíveis" = "Vagas")


### Vereador


ind_eleicoes_vr <- list()


for(ano in sort(unique(vr$ANO_ELEICAO))){
  for(municipio in sort(unique(vr$COD_MUN_TSE))){
    cat("Lendo",ano,municipio,"\n")
    
    ## Banco com os candidatos da proxima eleicao
    
    candidatos_ano2 <- filter(vr,
                              ANO_ELEICAO == ano + 4,
                              COD_MUN_TSE == municipio)
    ## Bancos com os candidatos eleitos na primeira e
    ## segunda eleicao de referencia
    
    eleitos_ano1 <- filter(cand_vr,
                           ANO_ELEICAO == ano,
                           COD_MUN_TSE == municipio)
    eleitos_ano2 <- filter(cand_vr,
                           ANO_ELEICAO == ano+4,
                           COD_MUN_TSE == municipio)
    ## Filtra os candidatos que se reapresentaram na eleicao
    ## seguinte e os que foram reeleitos
    
    eleitos_ano2 <- filter(eleitos_ano2, NUM_TITULO_ELEITORAL_CANDIDATO %in% 
                             eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO)
    indicadores1 <- filter(candidatos_ano2,
                           NUM_TITULO_ELEITORAL_CANDIDATO %in%
                             eleitos_ano1$NUM_TITULO_ELEITORAL_CANDIDATO) %>% 
      summarise(
        `Reapresentação` = n()
      )
    
    ## Dos candidatos que se reapresentaram na eleicao seguinte a
    ## eleicao de referencia, filtra-se somente os eleitos
    
    indicadores1$`Ano da eleição` <- ano + 4
    indicadores1$`Código do município` <- municipio
    indicadores2 <- eleitos_ano2 %>% 
      filter(DESC_SIT_TOT_TURNO == "ELEITO"|
               DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA"|
               DESC_SIT_TOT_TURNO == "ELEITO POR QP") %>% 
      summarise(
        Reeleitos = n()
      )
    
    ## Remove os bancos que nao serao mais utilizados
    
    rm(eleitos_ano1,eleitos_ano2)
    
    ## Filtra nos bancos referentes as estatiscas gerais das
    ## eleicoes, somente os anos que estao sendo 
    ## utilizados no momento  
    estatisticas_ano1 <- filter(vr1,
                                `Ano da eleição` == ano,
                                `Código do município` == municipio)
    estatisticas_ano2 <- filter(vr1,
                                `Ano da eleição` == ano + 4,
                                `Código do município` == municipio)
    
    if(nrow(estatisticas_ano1) > 0){

    
    ## Acrescenta as colunas `Ano de eleição` bancos gerados
    
    indicadores1$`Ano da eleição` <- ano + 4
    indicadores1$`Código do município` <- municipio
    indicadores2$`Ano da eleição` <- ano + 4
    indicadores2$`Código do município` <- municipio
    
    ## Junta os bancos em um unico  
    
    indicadores1 <- left_join(indicadores1,
                              indicadores2)
    
    ## Calculo dos indicadores de renovacao parlamentar  
    
    indicadores1$Derrotados <- indicadores1$Reapresentação - indicadores1$Reeleitos
    indicadores1$Desistência <- unique(estatisticas_ano1$Vagas) - indicadores1$Reapresentação
    if(indicadores1$Reapresentação > 0){
      indicadores1$`Conservação` <- conserv(indicadores1$Reeleitos, 
                                            indicadores1$Derrotados)
      indicadores1$`Renovação bruta` <- renov_br(indicadores1$Desistência,
                                                 indicadores1$Derrotados, 
                                                 unique(estatisticas_ano1$Vagas))
      indicadores1$`Renovação líquida` <- renov_liq(indicadores1$Derrotados, 
                                                    indicadores1$Reeleitos)
    }
    ## Empilha todas as eleicoes 
    
    ind_eleicoes_vr <- bind_rows(ind_eleicoes_vr,indicadores1)
    }
  }
}


## Remove as linhas desnecessarias

ind_eleicoes_vr <- na.omit(ind_eleicoes_vr)

municipios <- vr1 %>% 
  select(`Ano da eleição`,
         UF,
         `Código do município`, 
         `Nome do município`, 
         Vagas)

municipios <- unique(municipios)

ind_eleicoes_vr$Cargo <- "Vereador"


ind_eleicoes_vr <- left_join(ind_eleicoes_vr, municipios)


## Reorganiza a tabela

ind_eleicoes_vr <- ind_eleicoes_vr %>% 
  select(`Ano da eleição`,
         UF,
         `Código do município`,
         `Nome do município`,
         Cargo,
         Vagas,
         Reapresentação,
         Reeleitos,
         Conservação,
         `Renovação bruta`,
         `Renovação líquida`) %>% 
  dplyr::rename("Cadeiras disponíveis" = "Vagas")

# 3. Padronização ----------------------------------------------------------------------

## Padroniza o formato dos indices numericos

options(OutDec= ",")

### Deputado Federal (Brasil)

ind_eleicoes_fed_br$Conservação <- 
  format(round(ind_eleicoes_fed_br$Conservação, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_fed_br$`Renovação bruta` <- 
  format(round(ind_eleicoes_fed_br$`Renovação bruta`, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_fed_br$`Renovação líquida` <- 
  format(round(ind_eleicoes_fed_br$`Renovação líquida`, 
               digits = 2),  
         nsmall = 2)


### Deputado Federal (UF)

ind_eleicoes_fed_uf$Conservação <- 
  format(round(ind_eleicoes_fed_uf$Conservação, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_fed_uf$`Renovação bruta` <- 
  format(round(ind_eleicoes_fed_uf$`Renovação bruta`, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_fed_uf$`Renovação líquida` <- 
  format(round(ind_eleicoes_fed_uf$`Renovação líquida`, 
               digits = 2),  
         nsmall = 2)


### Deputado Estadual

ind_eleicoes_est$Conservação <- 
  format(round(ind_eleicoes_est$Conservação, 
               digits = 2),  
         nsmall = 2)


ind_eleicoes_est$`Renovação bruta` <- 
  format(round(ind_eleicoes_est$`Renovação bruta`, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_est$`Renovação líquida` <- 
  format(round(ind_eleicoes_est$`Renovação líquida`, 
               digits = 2),  
         nsmall = 2)

### Vereador


ind_eleicoes_vr$Conservação <- 
  format(round(ind_eleicoes_vr$Conservação, 
               digits = 2),  
         nsmall = 2)


ind_eleicoes_vr$`Renovação bruta` <- 
  format(round(ind_eleicoes_vr$`Renovação bruta`, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_vr$`Renovação líquida` <- 
  format(round(ind_eleicoes_vr$`Renovação líquida`, 
               digits = 2),  
         nsmall = 2)

ind_eleicoes_vr <- ind_eleicoes_vr %>% 
  arrange(UF)


## Junta os bancos de acordo com seu nivel de agregacao regional

### Renovacao parlamentar (UF)

ind_eleicoes_uf <- bind_rows(ind_eleicoes_fed_uf, ind_eleicoes_est)

# 4. Salvando os arquivos -------------------------------------------------

## Salva o arquivo referente aos indicadores de renovacao parlamentar em .csv

### Renovacao parlamentar (Brasil)

write.csv(ind_eleicoes_fed_br, "data/output/renov_parl_br.csv")

### Renovacao parlamentar (UF)

write.csv(ind_eleicoes_uf, "data/output/renov_parl_uf.csv")

### Renovacao parlamentar (Municipio)

write.csv(ind_eleicoes_vr, "data/output/renov_parl_mun.csv")


## Remove os arquivos que nao serao mais utilizados

rm(estatisticas_ano1,estatisticas_ano2,cand_de,cand_df,de,df,
   ind_eleicoes_est,ind_eleicoes_fed_br, ind_eleicoes_fed_uf, 
   ind_eleicoes_uf,ind_eleicoes_vr,indicadores1,indicadores2,
   candidatos_ano2,candidatos)
