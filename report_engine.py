"""Local analytics report exports. No unsupported predictive revenue claims."""
from __future__ import annotations
from datetime import datetime
from pathlib import Path
import pandas as pd
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from analytics_engine import segmentation, quality_report
from data_engine import CustomerDataset


def export_pdf(path: str | Path, ds: CustomerDataset, metrics: dict | None = None) -> None:
    page = SimpleDocTemplate(str(path), pagesize=A4, rightMargin=20*mm, leftMargin=20*mm, topMargin=18*mm, bottomMargin=18*mm)
    styles = getSampleStyleSheet()
    content = [Paragraph('Retention Intelligence | Churn Analysis', styles['Title']), Spacer(1, 10),
        Paragraph(f'Dataset: {ds.file_name}', styles['Normal']),
        Paragraph(f'Generated: {datetime.now():%Y-%m-%d %H:%M}', styles['Normal']),
        Paragraph('Historical / observed labels only. No forward-looking revenue or causal retention effect is implied.', styles['Italic']), Spacer(1, 18)]
    q = quality_report(ds)
    m = ds.metrics
    data = [['Metric','Observed value'],['Customers',str(m['total'])],['Labeled outcomes',str(m['known'])],['Churned',str(m['churned'])],['Retained',str(m['retained'])],['Observed churn rate',f"{m['rate']:.1f}%" if m['rate'] is not None else 'Unavailable'],['Duplicate customer IDs',str(q['duplicateIds'])],['Missing cells',str(q['missingCells'])]]
    def table(data):
        t = Table(data, colWidths=[86*mm,82*mm], repeatRows=1)
        t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#EAF2FF')),('TEXTCOLOR',(0,0),(-1,0),colors.HexColor('#1D4ED8')),('LINEBELOW',(0,0),(-1,-1),0.4,colors.HexColor('#DCE5F0')),('BOTTOMPADDING',(0,0),(-1,-1),9),('TOPPADDING',(0,0),(-1,-1),9)]))
        return t
    content.extend([table(data), Spacer(1,16), Paragraph('Churn by contract', styles['Heading2'])])
    groups = segmentation(ds,'Contract')
    if groups:
        content.append(table([['Contract','Observed churn rate']]+[[g['name'],f"{g['rate']:.1f}% (n={g['count']})"] for g in groups]))
    else:
        content.append(Paragraph('Unavailable: contract and labeled churn data required.',styles['Normal']))
    if metrics:
        content.extend([Spacer(1,14),Paragraph('Holdout ML evaluation',styles['Heading2']), Paragraph(f"Model: {metrics['model']}; train={metrics['trainRows']}, test={metrics['testRows']}; ROC-AUC={metrics['rocAuc']:.3f}; PR-AUC={metrics['prAuc']:.3f}. These are retrospective holdout metrics, not evidence of prospective forecasting.",styles['Normal'])])
    page.build(content)


def export_segments_csv(path: str | Path, ds: CustomerDataset) -> None:
    rows = []
    for dim in ['Contract','Tenure','Monthly charges','Payment method']:
        for g in segmentation(ds,dim):
            rows.append({'dimension':dim, **g})
    if not rows:
        raise ValueError('No segmented observations available for CSV export.')
    pd.DataFrame(rows).to_csv(path,index=False)
