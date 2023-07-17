function BusquedaFuerzaBruta(texto, patron: string): Integer;
var
  i, j: Integer;
begin
  // Recorremos todas las subcadenas del texto de la misma longitud que el patrón
  for i := 1 to Length(texto) - Length(patron) + 1 do
  begin
    j := 1;
    // Comparamos cada caracter de la subcadena con el patrón
    while (j <= Length(patron)) and (texto[i + j - 1] = patron[j]) do
      Inc(j);

    // Si el ciclo anterior termina porque j superó la longitud del patrón,
    // significa que se encontró una coincidencia y devolvemos el índice de inicio de la coincidencia.
    if j > Length(patron) then
    begin
      BusquedaFuerzaBruta := i;
      Exit;
    end;
  end;

  // Si no se encontró el patrón en el texto, devolvemos 0.
  BusquedaFuerzaBruta := 0;
end;

function BusquedaBoyerMoore(texto, patron: string): Integer;
var
  i, j, k, shift: Integer;
  tablaSalto: array [0..255] of Integer;
begin
  // Inicializamos la tabla de salto con la longitud del patrón en todas las entradas.
  for i := 0 to 255 do
    tablaSalto[i] := Length(patron);

  // Calculamos los saltos para cada caracter del patrón, excepto el último.
  for i := 1 to Length(patron) - 1 do
    tablaSalto[ord(patron[i])] := Length(patron) - i;

  // Iniciamos la búsqueda.
  i := Length(patron);
  while i <= Length(texto) do
  begin
    j := Length(patron);
    k := i - 1;

    // Comparamos el patrón desde el final hacia el principio con la subcadena del texto.
    while (j > 0) and (texto[k] = patron[j]) do
    begin
      Dec(j);
      Dec(k);
    end;

    // Si j llega a 0, significa que se encontró una coincidencia.
    if j = 0 then
    begin
      BusquedaBoyerMoore := k + 1;
      Exit;
    end
    else
    begin
      // Calculamos el desplazamiento para seguir buscando en el texto.
      shift := tablaSalto[ord(texto[i])] - Length(patron) + j + 1;
      if shift < 1 then
        shift := 1;
    end;

    // Aplicamos el desplazamiento para la siguiente iteración.
    i := i + shift;
  end;

  // Si no se encontró el patrón en el texto, devolvemos 0.
  BusquedaBoyerMoore := 0;
end;

procedure PreprocesarKMP(patron: string; var tablaSaltos: array of Integer);
var
  i, j: Integer;
begin
  i := 2;
  j := 0;
  tablaSaltos[1] := 0;

  // Preprocesamiento del patrón para obtener la tabla de saltos.
  while i <= Length(patron) do
  begin
    if patron[i] = patron[j + 1] then
    begin
      Inc(j);
      tablaSaltos[i] := j;
      Inc(i);
    end
    else if j > 0 then
    begin
      j := tablaSaltos[j];
    end
    else
    begin
      tablaSaltos[i] := 0;
      Inc(i);
    end;
  end;
end;

function BusquedaKMP(texto, patron: string): Integer;
var
  i, j: Integer;
  tablaSaltos: array [0..255] of Integer;
begin
  // Preprocesamos el patrón para obtener la tabla de saltos.
  PreprocesarKMP(patron, tablaSaltos);

  i := 1;
  j := 0;

  // Iniciamos la búsqueda utilizando la tabla de saltos.
  while i <= Length(texto) do
  begin
    if texto[i] = patron[j + 1] then
    begin
      Inc(i);
      Inc(j);

      // Si j llega a la longitud del patrón, se encontró una coincidencia.
      if j = Length(patron) then
      begin
        BusquedaKMP := i - j;
        Exit;
      end;
    end
    else if j > 0 then
    begin
      // Si no hay coincidencia, aplicamos el salto correspondiente de la tabla.
      j := tablaSaltos[j];
    end
    else
    begin
      Inc(i);
    end;
  end;

  // Si no se encontró el patrón en el texto, devolvemos 0.
  BusquedaKMP := 0;
end;
