Olá a todos os interessados.


Seguem abaixo instruções sobre este portfólio.


**1 - PROJETOS DE APIs SPRING BOOT**


As pastas CartorioService, SituacaoCartorioService, apireciclagem e eureka-server são projetos Spring Boot contendo APIs REST. Os 3 primeiros projetos citados estão vinculados
diretamente com o eureka-server, necessitando rodar o eureka-server para então rodar os outros serviços juntamente. Os projetos CartorioService e
SituacaoCartorioService contêm páginas HTML que consomem seus respectivos endpoints, utilizando JavaScript.

O projeto apireciclagem está configurado para rodar Docker, caso seja de interesse. E também está documentado com Swagger.


**2 - PROJETO ANGULAR CRUD**


Este projeto é um CRUD em Angular que consome os endpoints presentes em CartorioService.


**3 - PROJETO APLICATIVO-APPRECICLAGEM**


Este projeto consome em React Native os endpoints presentes em apireciclagem. Trata-se de um aplicativo para cadastro de empresas de reciclagem que são exibidas
no Google Maps para assim localizar a empresa mais próxima do seu endereço. O projeto não está totalmente implementado.


Observação 2: as IDEs utilizadas foram VS Code e Spring Tools Suite.