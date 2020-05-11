
%LLamamiento a la función
[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()
id_comunidad=7 % id comunidad: 7=CLM
name_ccaa{id_comunidad}   % nombre de comunidad
output.historic{id_comunidad} % estrucutura
y=output.historic{id_comunidad}.Cases% serie temporal de
plot(y) %dibuja casos activos
