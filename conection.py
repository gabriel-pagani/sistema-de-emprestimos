from pyodbc import connect, Error

def server_request(server: str, database: str, query_type: str, query: str) -> str:
    connection_data = f"DRIVER={{SQL Server}}; SERVER={server}; DATABASE={database};"
    message = ''

    try:
        with connect(connection_data) as connection:
            with connection.cursor() as cursor:
                formatted_query = query.strip().upper()
                cursor.execute(formatted_query)

                if query_type.lower() == 'view':
                    result = cursor.fetchall()
                    for row in result:
                        print(row)
                elif query_type.lower() == 'edit':
                    connection.commit()
                else:
                    raise ValueError('Valor inválido para o tipo da consulta')

                message = "\033[92mComando executado com sucesso!\033[m"

    except Error as e:
        message = f"\033[91mErro de conexão:\033[m \033[90m{e}\033[m"
    except ValueError as ve:
        message = f"\033[91mErro de valor:\033[m \033[90m{ve}\033[m"
    except Exception as e:
        message = f"\033[91mErro inesperado:\033[m \033[90m{e}\033[m"

    return message