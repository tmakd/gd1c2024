sqlcmd -S DESKTOP-86EVMU8\SQLEXPRESS02 -i migrations/create_db.sql, migrations/create_ddl_sp.sql, migrations/create_dml_sp.sql, migrations/migrate_ddl.sql, migrations/migrate_dml.sql -a 32767 -o resultado_output.txt


sqlcmd -S DESKTOP-86EVMU8\SQLEXPRESS02 -i run.sql -a 32767 -o resultado_output_unificado.txt