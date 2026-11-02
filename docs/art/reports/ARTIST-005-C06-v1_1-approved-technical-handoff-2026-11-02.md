# ARTIST-005 — C06 V1.1 | gate ART aprovado e handoff técnico

**Data:** 2026-11-02  
**Decisão do proprietário:** APPROVE C06 V1.1 (preview PNG exibido em chat).  
**Escopo da aprovação:** direção artística do template Active de duelo. **Não** equivale a sprite Godot integrado, aprovação de CI ou merge.

## Histórico preservado

- C01: moldura base aprovada; manter sem sobrescrever.
- C05 V3 e V3.1: histórico de aprovação preservado; C05 V3.2 (novo derivado) aprovado visualmente, com importação PNG pendente no PR #32.
- C05 FIT A: rejeitado; não reutilizar.
- C06 V1: preview SVG foi reportado como corrompido pelo proprietário; não promovê-lo como arte aprovada.
- **C06 V1.1:** novo preview raster gerado no chat e **aprovado explicitamente** pelo proprietário. A arte PNG não está presente nesta branch. O arquivo `docs/art/references/ARTIST-005-C06-active-concept-v1.svg` é somente histórico V1, não representa a V1.1 aprovada.

## Contrato visual C06 V1.1

1. Carta Active vertical, estilo cartoon vibrante e polido, contorno grosso azul/ciano e dourado, fundo navy.
2. Header com `NOME DA CARTA` e badge `TIPO`; painel de arte amplo com área segura, sem ilustração incorporada.
3. Seção `EFEITO / HABILIDADE` com espaço legível para texto.
4. Atributos `PV`, `ATQ`, `DEF` com ícones distintos e valores configuráveis.
5. Motivos urbanos discretos (graffiti/splashes), mantendo hierarquia de leitura e identidade própria sem associação com Pokémon/Digimon.
6. Render mobile-first; manter elementos da moldura e da ilustração separados no runtime.

## Plano de integração técnica (não executado)

| Etapa | Owner | Critério de aceite |
|---|---|---|
| 1. Importar o PNG V1.1 | ART | Arquivo raster efetivamente versionado com hash SHA-256, dimensões e metadados; não usar V1 SVG como substituto |
| 2. Revisar geometria e alpha | ART + ARCH | Proporção/safe-area/bleed, alpha e legibilidade verificados; preservar C01 |
| 3. Definir contrato visual | ARCH | Slots nome/tipo/arte/efeito/PV/ATQ/DEF mapeados, sem dados hardcoded |
| 4. Montar cena de QA | SCENE | CardVisualFramePreview.tscn reproduz a carta, respeitando o contrato existente e sem regressão |
| 5. Testes e evidências | INSPECTOR | Testes Godot headless, captura de preview e verificação visual mobile |
| 6. CI exact-head | SIGA | SHA fixado, checks verdes, sem conflitos/claims concorrentes antes de eventual merge |

**Restrições:** sem merge automático, sem avanço a C07, sem alteração do runtime até a importação do asset e gates pertinentes. PR #32 de C01/C05 permanece separado.

## Critérios de aceite

- [x] Gate artístico humano de C06 V1.1 registrado.
- [x] V1 SVG corrompido explicitamente despromovido.
- [ ] PNG aprovado versionado e hash verificado.
- [ ] ART/ARCH validam alpha, geometria e safe area.
- [ ] SCENE integra em cena QA sem alterar contratos existentes.
- [ ] INSPECTOR valida screenshots, testes e CI exact-head.
- [ ] Merge somente mediante autorização específica.
