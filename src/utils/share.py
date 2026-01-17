from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    HRFlowable,
    KeepTogether,
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.lib.enums import TA_CENTER, TA_RIGHT
from datetime import datetime

# ── Color palette ────────────────────────────────────────
PRIMARY = colors.HexColor("#2C3E50")
ACCENT = colors.HexColor("#3498DB")
POSITIVE = colors.HexColor("#27AE60")
NEGATIVE = colors.HexColor("#E74C3C")
LIGHT_BG = colors.HexColor("#F8F9FA")
GRAY = colors.HexColor("#7F8C8D")
DARK_GRAY = colors.HexColor("#34495E")
WHITE = colors.white
CARD_BORDER = colors.HexColor("#CBD5E0")


def header_footer(canvas, doc, trip_name="Trip Report"):
    """Generate a header for a page"""
    canvas.saveState()
    canvas.setFont("Helvetica", 9)
    canvas.setFillColor(GRAY)
    canvas.drawRightString(
        doc.rightMargin + doc.width, doc.pagesize[1] - 1.4 * cm, f"Page {doc.page}"
    )
    canvas.drawString(doc.leftMargin, doc.pagesize[1] - 1.4 * cm, trip_name)
    canvas.restoreState()


def create_pdf(trip, balances, settlements, path):
    """Generate PDF report for a trip"""

    doc = SimpleDocTemplate(
        str(path),
        pagesize=A4,
        rightMargin=2 * cm,
        leftMargin=2 * cm,
        topMargin=2.2 * cm,
        bottomMargin=2.2 * cm,
    )
    styles = getSampleStyleSheet()
    styles["Normal"].fontSize = 9.5
    styles["Normal"].leading = 13

    # ── Custom styles ────────────────────────────────────────
    title_style = ParagraphStyle(
        "Title",
        parent=styles["Heading1"],
        fontSize=26,
        textColor=PRIMARY,
        alignment=TA_CENTER,
        spaceAfter=8,
    )

    subtitle_style = ParagraphStyle(
        "Subtitle",
        parent=styles["Normal"],
        fontSize=10.5,
        textColor=GRAY,
        alignment=TA_CENTER,
        spaceAfter=24,
    )

    section_style = ParagraphStyle(
        "Section",
        parent=styles["Heading2"],
        fontSize=16,
        textColor=PRIMARY,
        spaceBefore=24,
        spaceAfter=8,
        leading=20,
    )

    stat_label_style = ParagraphStyle(
        "StatLabel",
        parent=styles["Normal"],
        fontSize=9.5,
        textColor=GRAY,
        alignment=TA_CENTER,
    )

    stat_value_style = ParagraphStyle(
        "StatValue",
        parent=styles["Normal"],
        fontSize=18,
        textColor=PRIMARY,
        alignment=TA_CENTER,
        spaceBefore=6,
        leading=20,
    )

    story = []

    # ── Header ───────────────────────────────────────────────
    story.append(Paragraph(trip["name"], title_style))
    created_date = datetime.fromisoformat(trip["created_at"]).strftime("%B %d, %Y")
    meta = f"Created {created_date}  •  {len(trip['participants'])} participants  •  {trip['currency']}"
    story.append(Paragraph(meta, subtitle_style))
    story.append(Spacer(1, 1.2 * cm))

    # ── Summary ──────────────────────────────────────────────
    total_expenses = sum(e["amount"] for e in trip["expenses"])
    avg_per_person = total_expenses / len(trip["participants"]) if trip["participants"] else 0
    expense_count = len(trip["expenses"])

    summary_data = [
        [
            Paragraph("Total Spent", stat_label_style),
            Paragraph("Expenses", stat_label_style),
            Paragraph("Avg / Person", stat_label_style),
        ],
        [
            Paragraph(f"{total_expenses:,.0f} {trip['currency']}", stat_value_style),
            Paragraph(f"{expense_count}", stat_value_style),
            Paragraph(f"{avg_per_person:,.0f} {trip['currency']}", stat_value_style),
        ],
    ]

    summary_table = Table(
        summary_data, colWidths=[5.6 * cm] * 3, rowHeights=[1.1 * cm, 1.7 * cm]
    )
    summary_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), LIGHT_BG),
                ("BOX", (0, 0), (-1, -1), 1, colors.HexColor("#D5DBDB")),
                ("INNERGRID", (0, 0), (-1, -1), 0.5, WHITE),
                ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 18),
                ("RIGHTPADDING", (0, 0), (-1, -1), 18),
                ("TOPPADDING", (0, 0), (-1, 0), 14),
                ("BOTTOMPADDING", (0, 1), (-1, 1), 18),
            ]
        )
    )
    story.append(KeepTogether(summary_table))
    story.append(Spacer(1, 1.3 * cm))

    # ── Expenses ─────────────────────────────────────────────
    story.append(Paragraph("Expenses Breakdown", section_style))
    story.append(
        HRFlowable(
            width="100%", thickness=1.2, color=ACCENT, spaceBefore=6, spaceAfter=8
        )
    )

    expense_data = [["Expense", "Amount", "Paid By", "Split", "Date"]]

    sorted_expenses = sorted(
        trip["expenses"], key=lambda x: x["created_at"], reverse=True
    )

    for e in sorted_expenses:
        payer_name = next(
            (m["name"] for m in trip["participants"] if m["id"] == e["paid_by"]), "Unknown"
        )
        expense_date = datetime.fromisoformat(e["created_at"]).strftime("%b %d")

        split_info = e.get("split_type", "equal").capitalize()
        if e.get("excluded"):
            split_info += f" – excl. {len(e['excluded'])}"

        expense_data.append(
            [
                e["title"],
                f"{e['amount']:,.2f}",
                payer_name,
                split_info,
                expense_date,
            ]
        )

    # expense_table = Table(expense_data, colWidths=[5 * cm, 3 * cm, 3 * cm, 3 * cm, 2 * cm])
    expense_table = Table(
        expense_data, colWidths=[5.8 * cm, 3.4 * cm, 3.4 * cm, 3.4 * cm, 2.2 * cm]
    )
    expense_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), DARK_GRAY),
                ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
                ("ALIGN", (1, 0), (1, -1), "RIGHT"),
                ("ALIGN", (4, 0), (4, -1), "CENTER"),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, 0), 10.5),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 9),
                ("TOPPADDING", (0, 0), (-1, 0), 9),
                ("LINEBELOW", (0, 0), (-1, 0), 1, GRAY),
                ("BACKGROUND", (0, 1), (-1, -1), WHITE),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, LIGHT_BG]),
                ("LINEBELOW", (0, 1), (-1, -1), 0.4, colors.HexColor("#E8ECEF")),
                ("FONTSIZE", (0, 1), (-1, -1), 9.5),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("RIGHTPADDING", (1, 0), (1, -1), 12),
            ]
        )
    )
    story.append(expense_table)
    story.append(Spacer(1, 1.2 * cm))

    # ── Balances ─────────────────────────────────────────────
    story.append(Paragraph("Participant Balances", section_style))
    story.append(
        HRFlowable(
            width="100%", thickness=1.2, color=ACCENT, spaceBefore=6, spaceAfter=8
        )
    )

    balance_data = [["Participant", "Paid", "Should Pay", "Balance"]]

    sorted_balances = sorted(
        balances.items(), key=lambda x: x[1]["balance"], reverse=True
    )

    total_paid = total_should = 0.0

    balance_text_style = ParagraphStyle(
        "BalanceText",
        parent=styles["Normal"],
        fontSize=10,
        alignment=TA_RIGHT,
    )

    for _, bal_info in sorted_balances:
        balance = bal_info["balance"]
        balance_color = POSITIVE if balance >= 0 else NEGATIVE
        sign = "+" if balance >= 0 else "−" if balance < 0 else ""
        balance_text = f"{sign}{abs(balance):,.2f}"

        balance_data.append(
            [
                bal_info["name"],
                f"{bal_info['total_paid']:,.2f}",
                f"{bal_info['should_pay']:,.2f}",
                Paragraph(
                    f"<font color='{balance_color.hexval()}'><b>{balance_text}</b></font>",
                    balance_text_style,
                ),
            ]
        )
        total_paid += bal_info["total_paid"]
        total_should += bal_info["should_pay"]

    balance_data.append(
        [
            Paragraph("<b>Grand Total</b>", styles["Normal"]),
            f"{total_paid:,.2f}",
            f"{total_should:,.2f}",
            "",
        ]
    )

    # balance_table = Table(balance_data, colWidths=[4 * cm, 4 * cm, 4 * cm, 4 * cm])
    balance_table = Table(balance_data, colWidths=[5 * cm, 4 * cm, 4 * cm, 4.2 * cm])
    balance_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), DARK_GRAY),
                ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
                ("ALIGN", (1, 0), (-1, -1), "RIGHT"),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, 0), 10.5),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 10),
                ("TOPPADDING", (0, 0), (-1, 0), 10),
                ("LINEBELOW", (0, 0), (-1, 0), 1, GRAY),
                ("BACKGROUND", (0, 1), (-1, -2), WHITE),
                ("ROWBACKGROUNDS", (0, 1), (-1, -2), [WHITE, LIGHT_BG]),
                ("LINEBELOW", (0, 1), (-1, -2), 0.4, colors.HexColor("#E8ECEF")),
                # Grand total styling
                ("BACKGROUND", (0, -1), (-1, -1), colors.HexColor("#ECF0F1")),
                ("FONTNAME", (0, -1), (2, -1), "Helvetica-Bold"),
                ("FONTSIZE", (0, -1), (-1, -1), 10),
                ("LINEABOVE", (0, -1), (-1, -1), 1.2, GRAY),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ]
        )
    )
    story.append(balance_table)
    story.append(Spacer(1, 1.2 * cm))

    # ── Settlements ──────────────────────────────────────────
    settlements_block = []
    settlements_block.append(Paragraph("Settlement Suggestions", section_style))
    settlements_block.append(
        HRFlowable(
            width="100%", thickness=1.2, color=ACCENT, spaceBefore=6, spaceAfter=8
        )
    )

    if not settlements:
        settlements_block.append(
            Paragraph("<i>All balances are settled! 🎉</i>", styles["Normal"])
        )
        settlements_block.append(Spacer(1, 0.8 * cm))
    else:
        for i, settlement in enumerate(settlements, 1):
            amount = settlement["amount"]
            from_color = NEGATIVE if amount > 0 else POSITIVE
            to_color = POSITIVE if amount > 0 else NEGATIVE
            arrow = " → " if amount > 0 else " ← "
            amt_abs = abs(amount)

            settlement_text = (
                f"<b>{i}.</b>   "
                f"<font color='{from_color.hexval()}'>{settlement['from_name']}</font>"
                f"{arrow}"
                f"<font color='{to_color.hexval()}'>{settlement['to_name']}</font>"
                f"   <b>{amt_abs:,.2f} {trip['currency']}</b>"
            )

            card = Table(
                [[Paragraph(settlement_text, styles["Normal"])]],
                colWidths=[16.2 * cm],
                cornerRadii=[4, 4, 4, 4],
            )
            card.setStyle(
                TableStyle(
                    [
                        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#FAFAFA")),
                        ("BOX", (0, 0), (-1, -1), 1, CARD_BORDER),
                        ("LEFTPADDING", (0, 0), (-1, -1), 16),
                        ("RIGHTPADDING", (0, 0), (-1, -1), 16),
                        ("TOPPADDING", (0, 0), (-1, -1), 10),
                        ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
                    ]
                )
            )
            settlements_block.append(KeepTogether(card))
            settlements_block.append(Spacer(1, 0.4 * cm))

    story.append(KeepTogether(settlements_block))

    # ── Footer ───────────────────────────────────────────────
    story.append(Spacer(1, 1.4 * cm))
    footer_style = ParagraphStyle(
        "Footer",
        parent=styles["Normal"],
        fontSize=8.5,
        textColor=GRAY,
        alignment=TA_CENTER,
    )
    story.append(
        Paragraph(
            f"Generated on {datetime.now().strftime('%B %d, %Y at %H:%M')}",
            footer_style,
        )
    )

    doc.build(
        story,
        onFirstPage=lambda c, d: header_footer(c, d, trip["name"]),
        onLaterPages=lambda c, d: header_footer(c, d, trip["name"]),
    )
