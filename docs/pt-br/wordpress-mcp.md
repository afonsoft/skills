# WordPress MCP
Esta skill expõe sites WordPress a agentes de IA via Model Context Protocol (MCP), cobrindo seleção de plugin, autenticação, transporte e configuração de clientes por plataforma.

## 🎯 Objetivo
Dar aos agentes controle seguro e autenticado do WordPress (posts, usuários, mídia, plugins, SEO, blocos Gutenberg) sem adivinhar endpoints ou esquemas de autenticação. Ela consolida três caminhos de integração complementares em um único guia de decisão.

## 🛠️ Como Funciona
A skill compara três caminhos e escolhe o que se adequa ao site alvo:
- **Caminho A — `wordpress/mcp-adapter` (oficial)**: Abilities API com 3 meta-tools, autenticação via Application Password, transporte HTTP + STDIO. Não precisa de composer na v0.6.1+.
- **Caminho B — AI Engine (comunidade)**: 43–109+ ferramentas admin prontas para uso atrás de um Bearer Token estático, somente HTTP. Caminho mais rápido para administração completa do WP.
- **Caminho C — wp-mcp-ultimate (comunidade)**: 58 abilities pré-construídas com OAuth 2.1, autocontido, funciona no WordPress 6.7+.

Em seguida, ela guia a instalação do plugin via WP-CLI, configuração de autenticação (Application Password / Bearer Token / OAuth), config do cliente MCP em Claude Code, Devin, OpenCode, Gemini, Codex, AGY e OpenClaw, e a verificação do endpoint.

## 🚀 Uso
Use esta skill quando o usuário quiser "configurar WordPress MCP", expor um site WordPress a agentes, corrigir um servidor `wordpress-*` que falha ao listar ferramentas, ou registrar abilities customizadas do WordPress. NÃO use para construir um servidor MCP customizado não relacionado ao WordPress (use `building-mcp-servers`).

## 🔗 Correlação
- **Integrações MCP**: Está ao lado de `composio-mcp` e `notebooklm-mcp` como a terceira integração MCP de serviço externo da coleção.
- **Extensibilidade**: Para construir um servidor MCP totalmente novo (não WordPress), combine com `building-mcp-servers`.
- **Migração**: O plugin depreciado `Automattic/wordpress-mcp` deve ser migrado para o Caminho A (`wordpress/mcp-adapter`).
