SELECT usuarios.name, problema.date_creation  as dt_abertura,  problema.closedate as dt_fechado, plugin.chamadasrecebidasfield as RECEBIDAS, plugin.chamadasrealizadasfield as REALIZADAS , plugin.retornosrealizadosfield as RETORNO
FROM glpi_problems_users AS users INNER JOIN glpi_users AS usuarios ON (usuarios.id = users.users_id) INNER JOIN glpi_problems AS problema ON (problema.id = users.problems_id) INNER JOIN glpi_plugin_fields_problemindicadordechamadas AS plugin
ON (plugin.items_id = users.problems_id) GROUP by usuarios.name
