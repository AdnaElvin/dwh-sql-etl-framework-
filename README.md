
---

## ⚙️ Main Components

### 1. [stg.pr_STG_Test_server.sql](./Store Procedure/stg.pr_STG_Test_server.sql)
stg.pr_STG_Test_server is a store procedure that sequentially executes all necessary staging procedures to load data from the Production1 and Production2 databases (located on test_server) into the staging environment.

### 2. `pr_ProdToSTG_SCD_Standart`
Executes a **standardized Slowly Changing Dimension (SCD)** logic with support for Type 1 and Type 2 changes using dynamic SQL.

---

## 💡 Purpose

- Dynamically generate column metadata for staging
- Automate the SCD logic (Type 1 and 2) using configuration tables
- Centralize transformation logic before pushing to the core DWH

---

## 🔒 License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

---

## 🧑‍💻 Author

Developed by Elvin Aliyev  
📍 Baku, Azerbaijan  
📧 [adna.elvin@gmail.com]

---

## 🚧 Roadmap

- [x] Build staging metadata logic
- [x] Support for multiple OLTP source servers
- [ ] Add DWH layer scripts (fact and dimension loading)
- [ ] Create monitoring and logging mechanism
- [ ] Include automated test cases

---

## 🤝 Contributions

Feel free to fork, raise issues, or suggest enhancements. Contributions are welcome!

