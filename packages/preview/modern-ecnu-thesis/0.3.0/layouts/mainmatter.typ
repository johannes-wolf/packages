#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": heading-content
#import "../utils/indent.typ": fake-par
#import "../utils/unpairs.typ": unpairs
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd
#import "../utils/word-counter.typ": *

#let mainmatter(
  // documentclass 传入参数
  doctype: "master",
  twoside: false,
  fonts: (:),
  // 其他参数
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  justify: true,
  first-line-indent: 2em,
  // 浮动于页顶或页底的上下间距
  figure-clearance: 24pt,
  figure-caption-spacing: 0.4em,
  numbering: custom-numbering.with(first-level: "第一章 ", depth: 4, "1.1 "),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.三号, 字号.四号, 字号.四号, 字号.小四),
  heading-weight: ("regular",),
  heading-above: (1.5em, 2.5em),
  heading-below: (2.0em, 1.5em),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  header-render: auto,
  header-vspace: 0em,
  display-header: false,
  stroke-width: 0.75pt,
  reset-footnote: true,
  // caption 的 separator
  separator: "  ",
  // caption 样式
  caption-style: text.with(font: 字体.楷体, style: "italic", size: 字号.小四),
  caption-size: 字号.小四,
  // figure 计数
  show-figure: i-figured.show-figure,
  // equation 计数
  show-equation: i-figured.show-equation,
  // heading 文字（本科生论文需要）
  heading-extra: "华东师范大学本科毕业论文",
  // 图表标题模式：standard 或 bilingual
  caption-mode: "standard",
  // 页码居中
  centered-page-number: false,
  ..args,
  it,
) = {

  pagebreak-from-odd(twoside: twoside)
  // // 0.  标志前言结束
  counter(page).update(1)
  set page(numbering: "1")

  set page(footer: context {
    set text(size: 字号.五号)
    let p = counter(page).get().at(0)
    let pagealign = center
    if calc.rem(p, 2) == 1 {
      pagealign = if (centered-page-number) { center } else { right }
    } else {
      pagealign = if (centered-page-number) { center } else { left }
    }
    align(pagealign, counter(page).display())
  })


  // 1.  默认参数
  fonts = 字体 + fonts
  if (text-args == auto) {
    text-args = (font: fonts.宋体, size: 字号.小四)
  }
  // 1.1 字体与字号
  if (heading-font == auto) {
    heading-font = (fonts.黑体,)
  }
  // 1.2 处理 heading- 开头的其他参数
  let heading-text-args-lists = args.named().pairs()
    .filter((pair) => pair.at(0).starts-with("heading-"))
    .map((pair) => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 3.  设置基本样式
  // 3.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    linebreaks: "optimized",
    first-line-indent: (amount: first-line-indent, all: true),
  )
  // show par: set block(spacing: spacing)
  show raw: set text(font: fonts.等宽, size: text-args.size)
  show raw.where(block: true): set par(leading: 1em)
  // 3.2 脚注样式
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  show footnote.entry: set par(leading: 1em)
  // 3.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: show-figure
  // 3.4 设置 equation 的编号和假段落首行缩进
  show math.equation.where(block: true): show-equation
  show math.equation.where(block: true): set block(inset: (y: 0.3em, x: 0em))
  // 3.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(size: caption-size, font: fonts.楷体)
  show figure.caption: set par(leading: 1em)

  show figure.caption: c => block(inset: (top: figure-caption-spacing, bottom: figure-caption-spacing))[
    #set align(left)
    #if caption-mode == "standard" {
      text(font: fonts.宋体, weight: "regular", style: "normal")[
      #c.supplement #context c.counter.display(c.numbering)
      ]
      h(0.3em)
      c.body
    } else if caption-mode == "bilingual" {
      c.body
    }
  ]

  show figure.where(placement: none): it => {
    v(figure-clearance / 6)
    it
    v(figure-clearance / 6)
  }
  set place(clearance: figure-clearance)
   // 3.6 优化列表显示
  //     术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: 0pt)
  show terms.item: it => block[
    #set par(hanging-indent: 2em)
    #text(font: fonts.黑体)[#it.term] #h(0.5em) #it.description
  ]
  // 3.7 处理链接样式
  show link: it => {
    set text(fill: color.rgb("#0066CC"))
    it
  }
  set table(stroke: 0.5pt + black)

  // 表格字体比正文小一号
  show table: set text(size: 0.95em)

  // 4.  处理标题
  // 4.1 设置标题的 Numbering
  set heading(numbering: numbering)
  // 4.2 设置字体字号并加入假段落模拟首行缩进
  show heading: it => context {
    set text(
      font: array-at(heading-font, it.level),
      size: if it.level == 1 {
          if state("in-mainmatter").get() { array-at(heading-size, it.level) } else {
            if doctype == "bachelor" { 字号.小三 } else { 字号.三号 }
          }
        } else { array-at(heading-size, it.level) },
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists
        .map((pair) => (pair.at(0), array-at(pair.at(1), it.level))))
    )
    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )
    it // fake-par + v(-0.15em) // no longer needed since 0.13.0
  }
  // 4.3 标题居中与自动换页
  show heading: it => context {
    if (array-at(heading-pagebreak, it.level)) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if ("label" not in it.fields() or str(it.label) != "no-auto-pagebreak") {
        pagebreak(weak: true)
      }
    }
    if (array-at(heading-align, it.level) != auto) {
      set align(if state("in-mainmatter").get() { array-at(heading-align, it.level) } else { center })
      it
    } else {
      it
    }
  }
  // 4.4 防止标题间距重复 https://github.com/typst/typst/issues/2953#issuecomment-1858823455
  show heading : it => context {
    // Finds all previous headings, inclusive
    let elems = query(selector(heading).before(here()))
    if elems.len() > 1 { // If there are at least 2
      let prev-heading = elems.at(-2)
      if (
        prev-heading.level > 1 and
        prev-heading.location().page() == it.location().page() and
        prev-heading.location().position().y + 60pt > it.location().position().y
      ) [
        #v(-calc.abs(array-at(heading-above, it.level) - array-at(heading-below, it.level)))
        #it
      ] else [
        #it
      ]
    } else [
      #it
    ]
  }

  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 5.  处理页眉
  set page(..(if display-header {
    (
      header: {
        if header-render == auto {
          heading-content(doctype: doctype, fonts: fonts)
        } else {
          header-render()
        }
        v(header-vspace)

      }
    )
  } else {
    (
      header: {
        // 重置 footnote 计数器
        if reset-footnote {
          counter(footnote).update(0)
        }
      }
    )
  }))

  // 斜体文字使用楷体
  show emph: set text(font: fonts.楷体)

  // 列表样式
  set enum(indent: 0.9em, body-indent: 0.35em)
  set list(indent: 1.2em, body-indent: 0.6em)

  // 引述文本样式
  set quote(block: true)
  show quote: set text(font: fonts.楷体)
  show quote: set pad(x: 2em)

  set underline(stroke: 0.5pt + black, offset: 0.35em)

  // 处理其他元素后第一段文本的首行缩进 (0.13.0 后不再需要)
  // show selector.or(figure, list, enum, quote, terms): it => {
  //   it + fake-par
  // }

  // 处理一级标题的引用格式
  show ref: it => {
    let el = it.element
    if (el != none and el.func() == heading and el.level == 1) {
      link(el.location(), text(fill: color.black,
        numbering(..counter(heading).at(el.location())).trim()
      ))
    } else {
      it
    }
  }

  // 字数统计（正文 + 附录）
  //   typst query main.typ '<total-words>' 2>/dev/null --field value --one
  context [
    #metadata(state("total-words-cjk").final()) <total-words>
    #metadata(state("total-characters").final()) <total-chars>
  ]

  // 用于本科毕业论文控制标题样式
  let s = state("in-mainmatter", true)
  context s.update(true)

  it
}