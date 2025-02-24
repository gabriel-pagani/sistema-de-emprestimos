from pyodbc import connect


def server_request(server, database, sql):
    connection_data = f"DRIVER={{SQL Server}}; SERVER={server}; DATABASE={database};"
    message = ''

    try:
        connection = connect(connection_data)
        cursor = connection.cursor()
        formatted_sql = sql.strip().upper()
        cursor.execute(formatted_sql)

        if formatted_sql.startswith(("SELECT")):
            result = cursor.fetchall()
            for row in result:
                print(row)
        else:
            connection.commit()

        message = "\033[92mComando executado com sucesso!\033[m"
        cursor.close()
        connection.close()

    except Exception as e:
        message = (
            f"\033[91mErro na conexão ou execução do comando:\033[m \033[90m{e}\033[m")

    finally:
        return message
