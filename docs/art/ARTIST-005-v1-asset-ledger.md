# ARTIST-005 — Inventário de assets V1 e ledger de aprovações

**Repositório:** az1nn/meme-mon  
**Data do gate T01:** 2026-10-10 (Brasil)  
**Estado:** INVENTORY ACTIVE; T01 CONCEPT_APPROVED; T02 COMPOSITION_APPROVED_1x1; T03 CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS; T04 CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS; T05 CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS; T06 CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS; T07 CONCEPT_APPROVED_MM06_GATED; T08 NEXT  
**Total:** 74 itens/famílias planejadas, **não** 74 imagens independentes nem 74 features autorizadas. Reusar componentes por padrão.

## Autoridade e fronteiras

- Estilo: ARTIST-003 cartoon-first tropical rooftop e ARTIST-004 screen-board aprovados. Preview do T01 tem novo aceite humano específico; as duas referências anteriores continuam valendo.
- **T01 é aprovado como composição/arte de tela (CONCEPT_APPROVED)**, não como licença de personagens, mascotes, logo final, regras, implementação Godot ou asset separado.
- V1: Godot Web local/in-memory, duelo determinístico; **G1 D card-first, G2 D, G3 C, G4 A, G5 C, G6 D, G7 B, G8 A, G9 D, G10 D provisório**. Sem login, multiplayer, monetização, catálogo público ou serviço remoto obrigatório.
- Os elementos ilustrativos do concept (nomes, nível, estrelas, botões `Item`/`Fugir`, posses, placares e valores arbitrários) **não alteram** Alpha 0.1. Implementação deve derivar ações/atributos válidos de `MatchState`/`PlayerIntent` e usar os cinco tipos canônicos **Classic, Reaction, Brainrot, Surreal, Wholesome**. `Mememom`, `Reaction` e `Format` são classes de carta, não raridades.
- A ordem P0/P1/P2 aqui é de **produção visual**, não reordena as dependências MM-06 → MM-07 → MM-08 no roadmap de produto.

## Gate específico T01 — aprovado

- **Arte fonte:** `duelo_tropical_de_cartas_no_rio.png`; preview 941 × 1672 px, RGB PNG.
- **SHA-256:** `79d2e9717022820aea46ae2cf052f11a880e90bf0e132293a65275aeebaa51c2` (calculado sobre os bytes locais do PNG gerado).
- **Decisão humana:** `APROVADO` explicitamente após exibição do T01.
- **Escopo aceito:** tela vertical de duelo, atmosfera cartoon urbana/tropical, duas cartas Active com ilustrações, composição de mão, ações contextuais, topo com hambúrguer e indicação do turno.
- **Pendências objetivas:** sem aprovação individual de P01/P06, sem marca final, sem confirmação de mecânicas sugeridas por labels ilustrativas, sem teste de toque/responsividade, sem screenshot real do Godot; validação ART/SCENE/ARCH/INSPECTOR ainda separada.
- **Importação binária no GitHub:** PENDING — não tratar SHA registrado como prova de arquivo anexado. Caminho sugerido quando for importado: `docs/art/references/ARTIST-005-T01-mobile-duel-approved.png`. Antes de marcar importação completa, verificar SHA exato da referência.

## Gate específico T02 — proporção e composição aprovadas

- **Arte fonte:** `MEMEMOM_ARTIST_T02_MENU_1x1_CORRIGIDO.png`, RGB PNG, **1254 × 1254 pixels**, ratio **1:1**.
- **SHA-256 da imagem:** `8c24fd7ee5925782b9395e93ff53c8f15a9e3b86b9dcdd9c9d5ab4c5574466f5` (bytes locais verificados 2026-10-10; 763366 bytes).
- **Gate humano:** `Correto` em resposta direta à pergunta `Essa proporção e composição estão corretas agora?` → **proporção e composição aprovadas**, sem extrapolar aprovação para rotas, economia, mascotes ou funcionalidades retratadas.
- **Escopo aceito:** quadrado 1:1; única composição com o menu aberto sobre a arena do duelo; geometria/proporções sem painéis verticais comprimidos; linguagem cartoon T01/ARTIST-004 preservada.
- **Correção preservada:** versões anteriores 1:1 com duas telas comprimidas lado a lado permanecem rejeitadas, não promover como novos baselines.
- **Gates ainda abertos:** selecionar no drawer **apenas Duelo e Coleção como rotas ativas**; outros itens ilustrativos (`Eventos`, `Ranking`, `Sair`, estatísticas, tutorial, moedas, níveis etc.) não são autorização de features. Validar dismissal por X/tap fora/back/Escape, foco acessível, Godot mobile/web screenshots em HEAD exato, contraste e touch. T02 não aprova personagens nem identidade de marca.
- **Repositório:** referência binária PNG **PENDING IMPORT**, proposta `docs/art/references/ARTIST-005-T02-hamburger-1x1-approved.png`. O ledger com hash verificado **não comprova importação binária**.
- **Próxima validação visual:** `T03` Duelo Desktop/Web responsivo, reutilizando os mesmos componentes e mantendo hambúrguer oculto por padrão.

## Gate específico T03 — visual desktop aprovado

- **Data da aprovação:** 2026-10-10 (Brasil); resposta humana exata: `Aprovado` após geração individual do preview T03.
- **Arte fonte:** `wide_colorful_cartoon_game_ui_concept_desktop_web.png` (1536 × 1024 px, PNG RGB; 2,515,561 bytes).
- **SHA-256 dos bytes originais:** `0053bc3108f17c927b4a7025324bc8990941f7ad27502a61c4c55b5b6c276e31`.
- **Estado:** `CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS`. Aceita a linguagem estética e distribuição de espaço desktop/web — cores, acabamento cartoon de personagens/cartas, cenografia urbana/tropical, composição horizontal e botões táteis.
- **Desvios ilustrativos NÃO normativos:** o preview inclui **sidebar global fixa** (contraria ARTIST-003/ART-002: hamburger-only, drawer oculto inicialmente), **combatentes externos às cartas** (G1 D: card-first), avatar/logo ainda não aprovados, **moedas, gemas, níveis, rede/social, eventos/ranking e ações específicas** fora do contrato V1. **A aprovação da imagem não altera essas decisões nem autoriza mecânicas**. Preservar a estética e aplicar contrato de T01/T02 + spec Alpha 0.1 em cenas Godot.
- **Sem finalização de implementação:** screenshot Godot, touch/mouse/teclado, responsividade, match-state/event binding, performance e acessibilidade continuam gates separados de SCENE/ARCH/INSPECTOR/SIGA; não inferir runtime PASS.
- **Importação binária no GitHub:** `PENDING`, destino sugerido `docs/art/references/ARTIST-005-T03-desktop-duel-approved.png`. Guardar bytes originais e verificar hash antes de declarar importação concluída.
- **Próximo item ARTIST:** `T04 — Coleção`, conceito individual preservando ARTIST-004/005 e UI voltada aos dados da coleção MM-05. Ainda precisa de aprovação individual.

## Gate específico T04 — conceito Coleção aprovado

- **Decisão humana:** `Aprovado` (2026-10-12, Brasil) após apresentação individual do preview T04.
- **Arquivo de origem:** `a_vibrant_colorful_cartoon_game_ui_screenshot_of.png`, PNG RGB, **1536 × 1024 px**.
- **SHA-256 exato:** `0494059bbd3e22692f6c9c9e30c1d00666d440e1926535818ae10f812d11f828` (arquivo original gerado na sessão).
- **Estado:** `CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS` — aprovação **do art concept** da Coleção, não do comportamento de gameplay nem dos nomes ou ilustrações particulares dos memes.
- **Direção aprovada:** grid colorido e responsivo de cartas ilustradas, estados de seleção legíveis, painel contextual de detalhes, campos de busca/filtros, contraste entre ilustrações e painéis, cartoon vibrante com contornos fortes e cenário urbano/tropical mais discreto.
- **Implementação vinculante (MM-05):** somente cartas/edições válidas e quantidade realmente possuída; busca por nome/ID; filtros por **kind, type e tier do schema**, sem substituir os tipos canônicos `Classic`, `Reaction`, `Brainrot`, `Surreal` e `Wholesome` por categorias ilustrativas (Fogo/Água/Planta etc.). Permitir inserir/remover cartas em draft conforme ownership e `DeckValidator`; não recalcular legitimidade na UI.
- **Correções obrigatórias ao implementar:** no preview há **sidebar global fixa** apesar do contrato ART-002 hamburger-only para mobile **e desktop**; usar trigger hambúrguer e drawer fechado por padrão. `Evoluir`, valores de moeda/gema, níveis/XP, "adquirido em", ranking/eventos, mecânicas e dados de cartas fictícios são decoração conceitual **não autorizada**. Remover/ocultar ações não suportadas, preservando a identidade visual.
- **Gate de personagens/marca:** as identidades e personagens individuais, a logo usada no conceito e eventuais elementos de marcas de terceiros **não** recebem aprovação separada de arte ou direitos. Sem public meme catalog (G9 D); G10 D captura progressiva de proveniência permanece provisória e inalterada.
- **Runtime/CI:** `NOT_VERIFIED`. Implementação Godot, navegação responsiva, touch/keyboard, overflow, ligação a MM-05 e screenshots reais do runtime ainda necessitam validação de SCENE/ARCH/INSPECTOR/SIGA.
- **Importação binária:** `PENDING`; caminho sugerido `docs/art/references/ARTIST-005-T04-collection-approved.png`. Comparar o hash dos bytes originais antes de declarar importação concluída.
- **Próximo gate ARTIST:** `T05 — Deckbuilder`, preview individual com deck de 30 cartas, quantidade possuída, validação determinística MM-05, estados de deck legal/ilegal e seleção/salvamento locais; nenhuma mecânica inventada.

## Gate específico T05 — conceito Deckbuilder aprovado

- **Decisão humana:** `Aprovado` (2026-10-12, Brasil), em resposta direta ao preview individual T05. **Escopo: ART CONCEPT**, não autorização para alterar mecânicas.
- **Imagem fonte:** `wide_colorful_cartoon_ui_game_interface_in_a_lands.png`, PNG RGB, **1536 × 1024 px**, **2.238.807 bytes**.
- **SHA-256 exato do PNG gerado:** `db54d0411814275fc9fc0925b44697b9a5e54b9d1074328f348a9a7d623c8632`.
- **Estado:** `CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS`.
- **Arte aprovada:** estética de card-based cartoon V1, cartões com silhuetas expressivas e bordas de cores distintas, contraste entre painel do deck e coleção disponível, tabs de decks locais, resumo visual, busca/filtragem e ações de salvar/testar visualmente distinguíveis.
- **Correção crítica de regras (MM-05 / Alpha 0.1):** alguns cards aparecem `x3` no mockup; **não permitidos** na V1. O limite é **2 cópias por `card_id`, incluindo múltiplas edições**, independentemente de quantidade possuída. Exatamente **30** entradas, no mínimo **8 Mememom** e no máximo **2 Headliners**. O selo `Deck válido` ilustrado **não comprova legalidade** de uma composição x3 nem validação real. Exibir resultados do `DeckValidator` autoritativo, inclusive erros `DECK_COPY_LIMIT`, `DECK_SIZE_INVALID`, `DECK_MIN_MEMEMOM`, `DECK_HEADLINER_LIMIT` e `CARD_NOT_OWNED`.
- **Correção de tipos:** os filtros exemplificativos `Fogo, Água, Planta, Elétrico, Psíquico, Noturno, Normal` **não substituem** `Classic`, `Reaction`, `Brainrot`, `Surreal`, `Wholesome`; distinguir `kind` (Mememom/Reaction/Format), `type` e `tier` reais conforme MM-03/MM-05.
- **Correção de navegação:** o preview contém sidebar fixa; no Godot mobile/desktop, **global hamburger-only**, sem navegação global permanentemente aberta. Manter layout desktop responsivo, fechamento e acessibilidade.
- **Elementos NÃO autorizados:** avatar, wordmark ilustrativa, moeda, gemas, nível/XP, notificações sociais, eventos/ranking, pacotes, novos efeitos ou personagens como Canon. `Novo Deck`/abas e `Testar Deck` só podem executar fluxos locais efetivamente implementados, sem recursos remotos.
- **Runtime:** `NOT_VERIFIED`; nenhum build, funcionamento de controles, armazenamento local, responsividade, teste em Godot ou revisão de direitos inferido a partir da imagem.
- **Binário no GitHub:** `PENDING_IMPORT`, caminho proposto `docs/art/references/ARTIST-005-T05-deckbuilder-approved.png`. Não marcar `IMPORTED` antes de upload e confirmação do SHA256.
- **Próxima unidade ARTIST:** `T06 — Detalhe da carta`: composição individual reutilizando C01–C12 e T01–T05, informações derivadas do schema MM-03; stats de combate somente para `Mememom`, sem botão de evolução ou mecânica não autorizada. Aprovação visual humana independente.

## Gate específico T06 — detalhe da carta aprovado

- **Decisão humana:** `Aprovado` após a geração individual do preview de Detalhe da Carta na sessão ARTIST, **2026-10-12 (Brasil)**.
- **Fonte original:** `a_bright_colorful_cartoon_game_ui_screen_in_the_s.png`, **PNG RGB 1536 × 1024**, **2.118.045 bytes**.
- **SHA-256 verificado:** `5ca939c0a25e393b0c52a6962751f477f94c60bb57f69b38a92dd16b34b55cdf`.
- **Estado:** `CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS`. Aceite da composição visual e acabamento — carta ilustrada ampliada como protagonista, detalhes textuais agrupados, badges legíveis, navegação entre cartas e ações destacadas. Não confirma direitos, identidade de personagem, novos mecanismos nem screenshot Godot.
- **Fonte técnica obrigatória:** `docs/specs/MM-03-card-schema-balance-budget.md`, contratos em `contracts/schemas/`, `MM-05`, ARTIST-003/004. Exibir somente atributos do `CardDefinition` por `kind`; `Mememom` pode mostrar HP e ataque baseline com custo, e `Reaction`/`Format` têm próprios campos de efeito. Usar `type` canônico `classic | reaction | brainrot | surreal | wholesome`, `tier` canônico, `trend_cost`, identificadores e efeitos realmente disponíveis. Não inferir `defesa`, `velocidade`, `altura`, `peso`, `nível`, `evolução` ou `habilidades` a partir do mockup.
- **Correções de produto obrigatórias:** ícone/etiqueta `Elétrico`, `Lv.`, botão `Evoluir`, árvores de evolução, perfil/moedas/gemas, data de aquisição inventada, atributos fantasia e campos de edição exibidos apenas como decoração, sem autorização. A UI deve omitir/desabilitar funcionalidades que não existem. `Adicionar ao Deck` só pode operar para cartas possuídas, com edição/quantidade válida e passagem pelo `DeckValidator`.
- **Limites do deck:** texto ilustrativo `Colecionado 3 cópias` não é necessariamente inválido como **quantidade possuída na coleção**; o contrato MM-05 limita **a 2 a quantidade selecionada por `card_id` no deck**, mesmo através de edições, sem afetar necessariamente a posse local.
- **Navegação canônica:** menu global sempre via **hambúrguer**, fechado por padrão em mobile e desktop. A sidebar permanente no conceito não altera ARTIST-003/ART-002.
- **Direitos e autoria:** Bicotech e outros mascotes, a wordmark ilustrada e os detalhes de arte são placeholders; aprovação da tela não aprova personagens individuais, branding ou catálogo público. `G9 D` e `G10 D` provisórios preservados.
- **Implementação/exact-head:** `NOT_VERIFIED` — sem teste de runtime, inspeção visual Godot, contraste e responsividade, prova de interações, import de PNG nem aprovação de direitos.
- **Importação binária GitHub:** `PENDING_IMPORT`, destino sugerido `docs/art/references/ARTIST-005-T06-card-detail-approved.png`; validar SHA-256 dos bytes reais antes de concluir importação.
- **Próximo gate visual:** `T07 — Meme Forge privado`, **CONCEPT ONLY** sujeito a MM-06. Upload/seleção de imagem **local**, edição de corte, nome, tipo canônico, prévia Sandbox, aviso de proveniência leve (inclusive `unknown`), sem publicação/rede/Canon, com aprovação visual humana individual.

## Gate específico T07 — Meme Forge privado aprovado

- **Decisão humana:** `Aprovado` em 2026-10-12 (Brasil), em resposta direta ao preview individual T07. A aprovação se restringe ao **art concept e hierarquia visual**; não autoriza a entrega funcional do MM-06 nem altera contrato de produto.
- **PNG de origem:** `a_vibrant_colorful_cartoon_game_ui_screenshot_in.png` — **1536 × 1024 px, RGB PNG**, **2.152.368 bytes**.
- **SHA-256 original verificado:** `cf45dcfb2a2b635d6263efe21bc79798f511c4418845a59c0cb1aca6f5415652`.
- **Estado:** `CONCEPT_APPROVED_MM06_GATED`. Visual aceito: editor de imagem com recorte, formulário simples, indicação de proveniência/privacidade, cartão ilustrado como preview, ações grandes, estética cartoon vibrante com acentos urbanos e composição desktop amigável.
- **Contrato técnico obrigatório:** MM-03, MM-05, MM-06 (ainda `NEXT` no roadmap), ARTIST-003/004. O Forge é **privado e local**; selecionar arquivos locais (upload aqui significa *file picker local*), cortar imagem, nomear, escolher **kind** `mememom | reaction | format` e **type** `classic | reaction | brainrot | surreal | wholesome`, e gerar stats/efeitos somente pelos limites e schemas MM-03, sem permitir código arbitrário. Não construir endpoint público, upload de mídia para servidor, login ou publicação.
- **Proveniência G10 D provisória:** perguntar no uso privado a origem/possíveis direitos e permitir explicitamente `desconhecida` sem impedir o Sandbox local. A frase fixa `Criada por você (G10 D)` no mockup **não comprova autoria/licença**: a UI precisa coletar declaração em vez de inferi-la. Se um futuro fluxo de publicação for autorizado, exigir evidências completas de direitos antes de qualquer submissão/revisão (MM-07/MM-08), fail-closed.
- **Desvios ilustrativos não autorizados:** filtros `Fogo/Água/Planta/Elétrico/Psíquico/Noturno/Normal` não são tipos canônicos; substituir pelos tipos reais. Avatar, wordmark, moedas/gemas, níveis, perfil online, notificações, eventos e ranking são apenas desenho. Menu lateral global **fixo** no preview não altera a regra: hambúrguer fechado por padrão no mobile **e** desktop. `Adicionar ao Deck` só deve ficar disponível quando a carta/edição local for válida e legal pelo domínio, considerando ownership e limite de 2 cópias por card_id; não prometer automaticamente card criado como competitivo/Canon.
- **Visual não autoriza elementos individuais:** cachorro, nomes, formatos ilustrativos da carta, marca e memes têm gates separados de originalidade/licenças/arte; G9 D privado primeiro continua valendo.
- **Gates ainda abertos:** validação de JSON/schema, recorte e importação Godot em navegador, armazenamento user:// com fallback volátil, funcionamento sem backend, acessibilidade e responsividade, comparativo LENTE/INSPECTOR no HEAD exato. `RUNTIME_NOT_VERIFIED`.
- **PNG no GitHub:** `PENDING_IMPORT`; caminho proposto `docs/art/references/ARTIST-005-T07-private-forge-approved.png`; antes de declarar importação, conferir bytes originais e SHA-256.
- **Próxima unidade ARTIST:** `T08 — Configurações e acessibilidade`, preview independente com seletor de 0/1/2 vídeos idle (0 inicial), movimento reduzido, fallback de imagem estática, som e controle de apresentação apenas onde suportados, mantendo navegação via hambúrguer e sem dependência online. A aprovação do preview não confirma implementação de configurações.

## Fila completa (um por vez)

### T — Telas V1

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| T01 | Duelo mobile card-first | P0 | CONCEPT_APPROVED |
| T02 | Menu hambúrguer aberto (mobile) | P0 | COMPOSITION_APPROVED_1x1 |
| T03 | Duelo desktop/web responsivo | P1 | CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS |
| T04 | Coleção | P1 | CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS |
| T05 | Deckbuilder | P1 | CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS |
| T06 | Detalhes da carta | P1 | CONCEPT_APPROVED_WITH_IMPLEMENTATION_CONSTRAINTS |
| T07 | Meme Forge privado | P2 | CONCEPT_APPROVED_MM06_GATED |
| T08 | Configurações e acessibilidade | P2 | NEXT |
| T09 | Resultado da partida | P2 | PENDING |
| T10 | Estados vazios/erros/armazenamento local | P2 | PENDING |

### C — Cartas

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| C01 | Moldura base comum | P0 | PENDING |
| C02 | Moldura rara | P1 | PENDING |
| C03 | Moldura épica | P1 | PENDING |
| C04 | Moldura lendária | P1 | PENDING |
| C05 | Verso de carta original | P0 | PENDING |
| C06 | Template Active (duelo) | P0 | PENDING |
| C07 | Template Hand (duelo) | P0 | PENDING |
| C08 | Template miniatura de coleção | P1 | PENDING |
| C09 | Badge de custo Trend | P0 | PENDING |
| C10 | Badge HP/estatísticas | P0 | PENDING |
| C11 | Badge tipo canônico | P1 | PENDING |
| C12 | Área de habilidade | P1 | PENDING |

### P — Ilustrações originais (nomes ilustrativos; não Canon)

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| P01 | Caramelo | P0 | PENDING_CHARACTER_REVIEW |
| P02 | Sapo Zinho | P0 | PENDING_CHARACTER_REVIEW |
| P03 | Gato de Rua | P0 | PENDING_CHARACTER_REVIEW |
| P04 | PombaTech | P1 | PENDING_CHARACTER_REVIEW |
| P05 | Axolote | P1 | PENDING_CHARACTER_REVIEW |
| P06 | Capivaro | P1 | PENDING_CHARACTER_REVIEW |

### U — Componentes UI/HUD

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| U01 | Botão primário contextual | P0 | PENDING |
| U02 | Botão secundário contextual | P0 | PENDING |
| U03 | Botão perigoso/destrutivo | P2 | PENDING |
| U04 | Header comum responsivo | P0 | PENDING |
| U05 | Gatilho hambúrguer | P0 | PENDING |
| U06 | Drawer sobreposto/fechamento | P0 | PENDING |
| U07 | Grupo de ações de duelo | P0 | PENDING |
| U08 | Container de mão local | P0 | PENDING |
| U09 | Indicador Hype (0–5) | P0 | PENDING |
| U10 | Indicador Trend/cap | P0 | PENDING |
| U11 | HP apenas em Mememom | P0 | PENDING |
| U12 | Filtros/tabs da coleção | P1 | PENDING |
| U13 | Campo busca coleção | P1 | PENDING |
| U14 | Modal/popup base | P2 | PENDING |
| U15 | Painel genérico de resultado (sem recompensas não previstas) | P2 | PENDING |

### I — Ícones e indicadores

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| I01 | Hambúrguer | P0 | PENDING |
| I02 | Coleção | P1 | PENDING |
| I03 | Deck | P1 | PENDING |
| I04 | Duelo | P1 | PENDING |
| I05 | Configurações | P1 | PENDING |
| I06 | Voltar | P1 | PENDING |
| I07 | Fechar | P1 | PENDING |
| I08 | Hype | P0 | PENDING |
| I09 | Trend | P0 | PENDING |
| I10 | HP | P0 | PENDING |
| I11 | Ataque | P1 | PENDING |
| I12 | Habilidade/efeito | P1 | PENDING |
| I13 | Ação contextual derivada do MatchState (não inventar item) | P2 | PENDING |
| I14 | Aviso offline/storage | P2 | PENDING |
| I15 | Placeholder/estado vazio | P2 | PENDING |

### B — Fundos reutilizáveis

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| B01 | Arena de duelo — terraço tropical cartoon | P0 | PENDING |
| B02 | Fundo para entry/home (opcional) | P1 | PENDING |
| B03 | Fundo coleção genérico reaproveitável | P1 | PENDING |
| B04 | Fundo deckbuilder (preferir B03 reaproveitado) | P1 | PENDING |
| B05 | Fundo resultado (preferir variação B01) | P2 | PENDING |
| B06 | Fundo estados/erros (preferir componentes genéricos) | P2 | PENDING |

### V — VFX de apresentação Godot

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| V01 | Ataque | P1 | PENDING |
| V02 | Habilidade | P1 | PENDING |
| V03 | Hit/dano | P1 | PENDING |
| V04 | KO | P2 | PENDING |
| V05 | Seleção/foco | P1 | PENDING |
| V06 | Active-card destaque | P1 | PENDING |

### M — Marca/apoio provisório

| ID | Asset / contrato | Prioridade | Estado |
|---|---|---|---|
| M01 | Wordmark original MEMEMOM | P2 | BRAND_GATE_OPEN |
| M02 | Símbolo/insígnia original | P2 | BRAND_GATE_OPEN |
| M03 | Banner interno (não requisito V1) | P3 | DEFERRED |
| M04 | Avatar genérico do player (não personagem final) | P2 | PENDING |

## Fluxo de produção e validação

1. **RECONCILE:** conferir asset ID, referência aprovada, branch/PR ativo, ownership e conflitos.
2. **GENERATE:** produzir exatamente **um preview por asset solicitado** e apenas as variantes necessárias, com arte no mesmo padrão V1 (não galeria multi-tela).
3. **HUMAN GATE:** aprovação explícita `APPROVED`, `ADJUST`, `REJECT`. Um aceite de tela não aprova automaticamente seus fragmentos e personagens.
4. **FREEZE CONCEPT:** guardar ID, versão, PNG original, dimensões, SHA256, escopo da aprovação, limitações e path/referência (não substituir silenciosamente versões aceitas).
5. **IMPLEMENT / VERIFY:** somente com escopo autorizado. SCENE integra Godot, ARCH verifica contratos, INSPECTOR compara evidências do runtime exato com o conceito; SIGA controla concorrência, testes, CI e handoff.
6. **REPORT:** sempre explicitar `CONCEPT_APPROVED` versus `RUNTIME_VERIFIED` e imagens binárias `IMPORTED` versus `PENDING`.

## Próxima unidade

**T08 — Configurações e acessibilidade:** gerar preview individual de configuração local (independente de conta/rede), no cartoon V1; preservar menu global hambúrguer oculto por padrão, controle manual de 0/1/2 vídeos idle Active (0 por padrão, G6–G8), política de preferência para dono do turno quando 1, fallback estático, movimento reduzido, som acessível e legibilidade. Não inventar sliders/persistência/serviços como funcionalidades entregues sem spec/runtime. **T07** está CONCEPT_APPROVED_MM06_GATED; MM-06 permanece sujeito a implementação/testes de domínio e navegador.

**Fase seguinte (sem geração automática):** validar T08 individualmente e seguir a fila; quando extrair assets unitários, priorizar base reutilizável B01/C01 antes de variantes de personagens, respeitando o pedido explícito do usuário.
