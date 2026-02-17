# Power BI DAX Key Insights

**Source:** /staging/blogs/powerbi-dax-tutorial.md  
**Extracted:** 2026-02-17 02:38 UTC  
**Type:** Insights / Tutorial Summary

---

## Overview

DAX (Data Analysis Expressions) เป็นภาษา formula สำหรับสร้าง custom calculations ใน Power BI ที่มีความสำคัญต่อนักพัฒนา Power BI เป็นอย่างมาก

---

## 5 Essential DAX Functions

### 1. CALCULATE - The Foundation
**Purpose:** เปลี่ยน context ของการคำนวณ เป็นฟังก์ชันที่สำคัญที่สุดใน DAX

```dax
Total Sales = CALCULATE(SUM(Sales[Amount]), Sales[Year] = 2023)
```

**Insight:** ใช้บ่อยที่สุด ควรเรียนรู้ให้ลึกซึ้งก่อนฟังก์ชันอื่น

---

### 2. FILTER - Data Subsetting
**Purpose:** Return filtered table ตามเงื่อนไขที่กำหนด

```dax
High Value Products = FILTER(Products, Products[Price] > 1000)
```

**Insight:** ใช้สำหรับกรองข้อมูลก่อนนำไปคำนวณ แต่ควรหลีกเลี่ยงถ้า CALCULATE ทำได้

---

### 3. SUMX - Iterator Function
**Purpose:** Iterate ผ่าน table และคำนวณ expression สำหรับแต่ละ row

```dax
Total Revenue = SUMX(Sales, Sales[Quantity] * Sales[UnitPrice])
```

**Insight:** จำเป็นสำหรับการคำนวณ row-by-row ก่อนรวมผล (เช่น Quantity × UnitPrice)

---

### 4. RELATED - Cross-Table References
**Purpose:** ดึงค่าจาก related table (one-to-many relationship)

```dax
Product Category = RELATED(Products[Category])
```

**Insight:** ทำให้สามารถใช้ข้อมูลจากตารางอื่นได้โดยไม่ต้อง flatten data model

---

### 5. DIVIDE - Safe Division
**Purpose:** หารที่มีการจัดการ error (division by zero)

```dax
Growth Rate = DIVIDE([This Year], [Last Year]) - 1
```

**Insight:** ปลอดภัยกว่าใช้ / ธรรมดา เพราะจัดการกรณี denominator เป็น 0 หรือ blank อัตโนมัติ

---

## Best Practices Summary

| Practice | Why It Matters |
|----------|----------------|
| Use variables | ทำให้ complex formulas อ่านง่ายและ debug สะดวก |
| Avoid FILTER when CALCULATE works | Performance optimization |
| Understand filter vs row context | Core DAX concept ที่ต้องเข้าใจ |
| Use DIVIDE instead of / | Safe division, no errors |
| Test with different scenarios | Ensure measures work correctly |

---

## Learning Path Recommendation

1. **เริ่มจาก:** CALCULATE (พื้นฐานที่สุด)
2. **ต่อด้วย:** SUMX และ RELATED (การคำนวณและดึงข้อมูล)
3. **จากนั้น:** FILTER และ DIVIDE (กรองและความปลอดภัย)
4. **สุดท้าย:** Advanced concepts และ optimization

---

## Tags
`power-bi` `dax` `data-analysis` `business-intelligence` `tutorial`

---

*Extracted and curated by ทัศน์ (Tars) for Ontoiq System*
