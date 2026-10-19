# V1 release accountability checklist

Nenhum item pode ser marcado somente por intenção ou por CI parcial. Registre commit, responsável e evidência verificável.

## Responsáveis do beta fechado

- Operador e responsável de release: az1nn / Mememom.
- Moderação: moderador e administrador; o administrador faz escalonamento e apelação quando disponível.
- Incidente, privacidade e segurança: operador do beta pelo canal privado fornecido aos participantes.

## Gates técnicos

- [ ] Suites MM-04 a MM-09 passam no mesmo commit exato.
- [ ] Snapshots MM-07, edição/legality MM-08 e replay MM-09 têm testes negativos de fronteira de confiança.
- [ ] PWA instala, atualiza e abre offline no navegador alvo.
- [ ] Android assinado instala e passa smoke em alvo suportado.
- [ ] Acessibilidade, touch, foco, contraste e revisão visual/original-brand têm aceite humano.

## Gates operacionais

- [ ] Política de beta fechado, código MIT/DCO, conduta, segurança e conteúdo/proveniência estão versionadas.
- [ ] Responsáveis e rota privada de incidentes foram confirmados aos participantes do beta.
- [ ] Antes de abertura pública: Private Vulnerability Reporting e contato verificável de moderação/privacidade estão publicados.
- [ ] Evidência de deploy, configuração de retenção e rota de escalonamento foi registrada sem expor segredos.

## Evidência de release

- [ ] Tag, checksum/commit, artefatos PWA/Android e resultados de smoke são registrados.
- [ ] Nenhuma carta Sandbox, submissão não aprovada ou edição suspensa aparece em deck/match competitivo.
- [ ] O release declara beta fechado enquanto os gates públicos permanecerem pendentes.
