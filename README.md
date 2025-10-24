# 💡 Proiect FPGA – Joc Interactiv cu FSM, LED-uri și Afișaj 7 Segmente

Acest proiect a fost realizat în **Vivado Design Suite** și implementează un **joc interactiv digital** bazat pe o **mașină de stări finite (FSM)**.  
Proiectul folosește **comutatoare de intrare**, **LED-uri de ieșire**, **generator de număr aleator**, **contor de scor** și un **afișaj cu 7 segmente** controlat printr-un driver dedicat.

---

## 🧠 Schema bloc a sistemului

![Schema bloc](schema_bloc_scid.png)

---

## ⚙️ Structura proiectului

Sistemul este format din următoarele module principale:

1. **Comutatoare de intrare (SW)**  
   – Permite utilizatorului să interacționeze cu jocul prin setarea unor combinații binare de intrare.

2. **Unitate de control (FSM)**  
   – Controlează stările sistemului și logica de joc (inițializare, comparație, incrementare scor etc.).  
   – Coordonează comunicația dintre toate modulele.

3. **Generator de număr aleator**  
   – Produce o valoare binară aleatorie care reprezintă “numărul țintă” al jocului.

4. **Contor de scor**  
   – Incrementat automat atunci când utilizatorul introduce corect combinația de intrare.

5. **Driver afișaj 7 segmente**  
   – Primește valoarea scorului și o afișează pe un afișaj cu 7 segmente.

6. **LED-uri de ieșire**  
   – Indică vizual rezultatul comparației dintre valoarea introdusă și cea generată aleator.

---

## 📂 Fișiere incluse

| Tip fișier | Nume | Descriere |
|-------------|------|------------|
| `FSM.vhd` | Unitatea de control principală – mașina de stări finite |
| `driver7seg.vhd` | Modul de afișare pe 7 segmente |
| `constr.xdc` | Fișier de constrângeri pentru pini FPGA |
| `FSM_propImpl.xdc` | Versiune alternativă de constrângeri (pentru implementare) |
| `Surse_Proiect_Vivado.txt` | Descriere generală și notițe despre surse |
| `schema_bloc_scid.png` | Schema bloc generală a sistemului |

---

## 🧩 Platformă hardware

Proiectul este destinat rulării pe o placă FPGA compatibilă (ex. **Xilinx Artix-7** sau **Basys 3**)  
și utilizează limbajul de descriere hardware **VHDL**.

---

## 🧑‍💻 Autor

**Mihuț Darius Daniel**  
Facultatea de Electronică, Telecomunicații și Tehnologia Informației  
Universitatea Tehnică din Cluj-Napoca

---

## 🏁 Concluzie

Proiectul demonstrează integrarea mai multor module logice într-un sistem complet controlat de o FSM, oferind o interacțiune intuitivă între utilizator și dispozitiv, prin LED-uri și afișaj numeric.

---
