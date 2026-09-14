import { Marked } from 'marked'
import { readFileSync, writeFileSync, readdirSync } from 'node:fs'
import { dirname, join, basename } from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = dirname(fileURLToPath(import.meta.url))

/**
 * Builds a printable HTML page from each Markdown source in this folder.
 *
 * The Markdown is the single source of truth. Editing the HTML by hand means it
 * drifts from the Markdown within a week, so it is generated instead.
 */

const marked = new Marked({ gfm: true, breaks: false })

const STYLE = `
  :root {
    --deep: #04283f;
    --ink: #1a2b35;
    --muted: #5d7383;
    --line: #dde5ea;
    --sand: #f5f2ec;
    --accent: #0b7f79;
    --code-bg: #f4f6f8;
  }

  * { box-sizing: border-box; }

  body {
    margin: 0;
    padding: 48px 24px 96px;
    font-family: "Charter", "Georgia", "Iowan Old Style", serif;
    font-size: 16px;
    line-height: 1.7;
    color: var(--ink);
    background: #fff;
  }

  main { max-width: 820px; margin: 0 auto; }

  h1, h2, h3, h4 {
    font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    line-height: 1.25;
    color: var(--deep);
  }

  h1 {
    font-size: 2.1rem;
    margin: 0 0 8px;
    padding-bottom: 16px;
    border-bottom: 3px solid var(--accent);
  }

  h2 {
    font-size: 1.45rem;
    margin: 48px 0 14px;
    padding-top: 20px;
    border-top: 1px solid var(--line);
  }

  h3 { font-size: 1.12rem; margin: 30px 0 10px; }
  h4 { font-size: 1rem; margin: 22px 0 8px; color: var(--muted); }

  p { margin: 0 0 14px; }

  a { color: var(--accent); }

  code {
    font-family: ui-monospace, "SF Mono", "Cascadia Code", Menlo, monospace;
    font-size: 0.86em;
    background: var(--code-bg);
    padding: 2px 5px;
    border-radius: 4px;
  }

  pre {
    background: var(--code-bg);
    border: 1px solid var(--line);
    border-radius: 8px;
    padding: 14px 16px;
    overflow-x: auto;
    line-height: 1.55;
  }

  pre code { background: none; padding: 0; font-size: 0.82rem; }

  blockquote {
    margin: 18px 0;
    padding: 12px 18px;
    background: var(--sand);
    border-left: 4px solid var(--accent);
    border-radius: 0 8px 8px 0;
  }

  blockquote p:last-child { margin-bottom: 0; }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 18px 0;
    font-size: 0.92rem;
  }

  th, td {
    border: 1px solid var(--line);
    padding: 9px 12px;
    text-align: left;
    vertical-align: top;
  }

  th { background: var(--sand); font-weight: 600; }

  img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 20px auto;
    border: 1px solid var(--line);
    border-radius: 8px;
  }

  figure { margin: 26px 0; }
  figcaption {
    text-align: center;
    font-size: 0.86rem;
    color: var(--muted);
    margin-top: -8px;
  }

  ul, ol { margin: 0 0 14px; padding-left: 26px; }
  li { margin-bottom: 6px; }

  hr { border: 0; border-top: 1px solid var(--line); margin: 40px 0; }

  .doc-footer {
    margin-top: 64px;
    padding-top: 18px;
    border-top: 1px solid var(--line);
    font-size: 0.82rem;
    color: var(--muted);
    font-family: ui-sans-serif, system-ui, sans-serif;
  }

  @media print {
    body { padding: 0; font-size: 11.5pt; }
    h1, h2, h3, h4 { break-after: avoid; }
    pre, table, figure, img { break-inside: avoid; }
    a { color: var(--ink); text-decoration: none; }
    .doc-footer { display: none; }
    @page { margin: 18mm 16mm; }
  }
`

function page(title, bodyHtml) {
  return `<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${title}</title>
<style>${STYLE}</style>
</head>
<body>
<main>
${bodyHtml}
<p class="doc-footer">Appnea &mdash; dibuat dari <code>${title}</code>. Untuk PDF: buka di browser lalu Print &rarr; Save as PDF.</p>
</main>
</body>
</html>
`
}

const sources = readdirSync(HERE).filter((name) => name.endsWith('.md'))

for (const source of sources) {
  const markdown = readFileSync(join(HERE, source), 'utf-8')
  const firstHeading = markdown.match(/^#\s+(.+)$/m)?.[1] ?? basename(source, '.md')
  const target = source.replace(/\.md$/, '.html')

  writeFileSync(join(HERE, target), page(firstHeading, marked.parse(markdown)))
  console.log(`built ${target}  (from ${source})`)
}
