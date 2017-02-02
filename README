Projeto utilizando ElasticSearch + Kibana na tentativa de auxiliar a transparência da Universidade Federal do Paraná (UFPR).

Árvore de Diretórios:

.
├── Dados\_Servidores - Contém uma diretório para cada mês.
│   ├── 2016-12 - Diretório que contém os CSVs referentes a Dezembro de 2016.
│   ├── 2016-11 - Diretório que contém os CSVs referentes a Novembro de 2016.
│   ├── ...
│   └── Processados - Diretório que contém CSVs resultantes da união de CSVs do portal transparência.
├── configs - Diretório com arquivos de configuração para unir CSVs do portal transparência em um só, que é inserido no Kibana/ElasticSearch.
├── config.json.example - Exemplo de arquivo do diretório 'configs'.
├── logstash\_configs - Diretório com arquivos de configuração do Logstash para inserção de dados no Kibana/ElasticSearch.
├── logstash\_config.example - Exemplo de arquivo do diretório 'logstash\_configs'. É usado pelo script 'create\_config.py' para gerar o arquivo de configuração do logstash.
├── create\_config.py - Script que cria arquivos de configuração que ficam contidos nos diretórios 'configs' e 'logstash\_configs'.
├── resumo\_cadastro.sh - Script que filtra dados do CSV de Cadastro do Portal Transparência, selecionando dados das Universidades interessantes para este projeto.
├── merge\_files\_es.py - Script que usa um arquivo de configuração do diretório 'configs' para unir dois CSVs (Cadastro e Remuneração) do portal transparência em um só e salvá-lo no diretório Dados\_Servidores/Processados
└── insert\_data.sh - Script que gerencia os outros scripts.
