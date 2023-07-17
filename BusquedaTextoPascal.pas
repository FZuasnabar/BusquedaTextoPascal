program SistemaMenu;

{$mode objfpc}{$H+}

uses
  SysUtils,
  Classes,
  DateUtils,
  StrUtils, //libreria para utilizar pos y posEx
  crt;

const
  MAX_USUARIOS = 5;

type
  TUsuario = record
    Nombre: string;
    Contrasena: string;
  end;

  THistorial = record
    TextoElegido: string;
    TextoBuscado: string;
    TiempoBusqueda: Double;
    CantidadApariciones: Integer;
  end;

var
  Usuarios: array [1..MAX_USUARIOS] of TUsuario;
  TextosCargados: TStringList; // Variable global para almacenar los textos cargados
  Historial: array of THistorial; // Array dinámico para almacenar el historial de búsquedas


function BusquedaFuerzaBruta(texto, patron: string): Integer;
    var
    i, j: Integer;
    begin
    for i := 1 to Length(texto) - Length(patron) + 1 do
      begin
        j := 1;
        while (j <= Length(patron)) and (texto[i + j - 1] = patron[j]) do
        Inc(j);

        if j > Length(patron) then
        begin
          BusquedaFuerzaBruta := i;
          Exit;
        end;
      end;

      BusquedaFuerzaBruta := 0; // Si no se encontró el patrón en el texto
    end;

function BusquedaBoyerMoore(texto, patron: string): Integer;
  var
    i, j, k, shift: Integer;
    tablaSalto: array [0..255] of Integer;
  begin
    for i := 0 to 255 do
      tablaSalto[i] := Length(patron);

    for i := 1 to Length(patron) - 1 do
      tablaSalto[ord(patron[i])] := Length(patron) - i;

    i := Length(patron);
    while i <= Length(texto) do
    begin
      j := Length(patron);
      k := i - 1;
      while (j > 0) and (texto[k] = patron[j]) do
      begin
        Dec(j);
        Dec(k);
      end;

      if j = 0 then
      begin
        BusquedaBoyerMoore := k + 1;
        Exit;
      end
      else
      begin
        shift := tablaSalto[ord(texto[i])] - Length(patron) + j + 1;
        if shift < 1 then
          shift := 1;
      end;

      i := i + shift;
    end;

    BusquedaBoyerMoore := 0; // Si no se encontró el patrón en el texto
  end;

procedure PreprocesarKMP(patron: string; var tablaSaltos: array of Integer);
  var
    i, j: Integer;
  begin
    i := 2;
    j := 0;
    tablaSaltos[1] := 0;

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
    PreprocesarKMP(patron, tablaSaltos);
    
    i := 1;
    j := 0;

    while i <= Length(texto) do
    begin
      if texto[i] = patron[j + 1] then
        begin
          Inc(i);
          Inc(j);
          if j = Length(patron) then
            begin
              BusquedaKMP := i - j;
              Exit;
            end;
        end
      else if j > 0 then
        begin
          j := tablaSaltos[j];
        end
      else
        begin
          Inc(i);
        end;
    end;

    BusquedaKMP := 0; // Si no se encontró el patrón en el texto
  end;

function CantidadApariciones(textoSeleccionado, palabraBuscada: string): Integer;
    var
    contador, posicion: Integer;
    begin
    contador := 0;
    posicion := Pos(palabraBuscada, textoSeleccionado);
    while posicion > 0 do
    begin
        Inc(contador);
        posicion := PosEx(palabraBuscada, textoSeleccionado, posicion + Length(palabraBuscada));
    end;
    CantidadApariciones := contador;
    end;

procedure VerApariciones(textoSeleccionado, palabraBuscada: string);
    var
    inicio, fin, posicion, longitudContexto, contador: Integer;
    contexto: string;
    begin
    longitudContexto := 20; // Longitud del contexto a imprimir
    contador := 1; // Contador para numerar los contextos

    writeln('Apariciones de "', palabraBuscada, '":');

    posicion := Pos(palabraBuscada, textoSeleccionado);
    while posicion > 0 do
        begin
            inicio := posicion - longitudContexto;
            if inicio < 1 then
            inicio := 1;

            fin := posicion + Length(palabraBuscada) + longitudContexto - 1;
            if fin > Length(textoSeleccionado) then
            fin := Length(textoSeleccionado);

            contexto := Copy(textoSeleccionado, inicio, fin - inicio + 1);

            writeln('Contexto ', contador, ': "', contexto, '"');

            posicion := PosEx(palabraBuscada, textoSeleccionado, posicion + Length(palabraBuscada));
            Inc(contador);
        end;
    end;

procedure agregarAlHistorial(textoElegido: Integer; palabraBuscada: string; duracion: Double; cantidad: Integer);
    var
    historialLength: Integer;
    begin
    historialLength := Length(Historial);
    SetLength(Historial, historialLength + 1);
    Historial[historialLength].TextoElegido := 'Texto ' + IntToStr(textoElegido);
    Historial[historialLength].TextoBuscado := palabraBuscada;
    Historial[historialLength].TiempoBusqueda := duracion;
    Historial[historialLength].CantidadApariciones := cantidad;
    end;

procedure InicializarUsuarios;
    begin
    Usuarios[1].Nombre := 'fAlejandra';
    Usuarios[1].Contrasena := '20194079';
    Usuarios[2].Nombre := 'jMaria';
    Usuarios[2].Contrasena := '20170766';
    Usuarios[3].Nombre := 'sDaniella';
    Usuarios[3].Contrasena := '20162536';
    Usuarios[4].Nombre := 'zRobert';
    Usuarios[4].Contrasena := '20202308';
    Usuarios[5].Nombre := 'zFernando';
    Usuarios[5].Contrasena := '20202333';
    end;



procedure RegistrarTexto;
    var
      archivo: Text;
      nombreArchivo: string;
      linea: string;
      textoCargado: string;
    begin
      Write('Ingrese el nombre del archivo: ');
      Readln(nombreArchivo);
      //BLOQUE TRY
      try
        Assign(archivo, nombreArchivo);
        Reset(archivo);

        textoCargado := '';

        while not EOF(archivo) do
        begin
        ReadLn(archivo, linea);
        textoCargado := textoCargado + linea + ' ';
        end;

        Close(archivo);

        textosCargados.Add(textoCargado); // Agregar el texto cargado a la lista de textos
        WriteLn('Carga exitosa');
      //CATCH O EXCEPT
      except
        on E: EInOutError do
        begin
        WriteLn('Ruta invalida');
        end;
    end;
  end;

procedure BuscarTexto;
  var
    i: Integer;
    algoritmoBusqueda, textoSeleccionado, palabraBuscada: string;
    opcion: Integer;
    eleccion: Integer;
    indiceTexto: Integer;
    encontrado: Boolean;
    cantidad: Integer;
    inicio, fin: TDateTime;
    duracion: Double;
  begin
    clrscr;
    writeln('=== BUSCAR TEXTO ===');
    writeln;

    if TextosCargados.Count = 0 then
    begin
      writeln('Aun no se han cargado textos.');
      Exit;
    end;

    // Mostrar los textos disponibles numerados
    writeln('Textos disponibles:');
    for i := 1 to TextosCargados.Count do
      writeln(i, '. Texto ', i);
    writeln;

    write('Seleccione un numero de texto: ');
    readln(opcion); 

    // Verificar si la opción seleccionada es válida
    if (opcion < 1) or (opcion > TextosCargados.Count) then
    begin
      writeln('Numero de texto invalido.');
      Exit;
    end;

    // Obtener el índice del texto elegido
    indiceTexto := opcion - 1;

    // Acceder al texto seleccionado en Textos utilizando el índice obtenido
    textoSeleccionado := TextosCargados[indiceTexto];

    // Mostrar los algoritmos de búsqueda disponibles y solicitar al usuario que elija uno
    writeln('Algoritmos de busqueda disponibles:');
    writeln('1. Fuerza Bruta');
    writeln('2. Boyer-Moore');
    writeln('3. Knuth-Morris-Pratt');
    writeln;

    write('Seleccione un algoritmo de busqueda: ');
    readln(algoritmoBusqueda);

    // Solicitar al usuario que ingrese una palabra
    write('Ingrese una palabra a buscar: ');
    readln(palabraBuscada);

    // Obtener el tiempo de inicio de la búsqueda
    inicio := Now;

    // Realizar la búsqueda según el algoritmo seleccionado
    encontrado := False;
    case algoritmoBusqueda of
      '1': encontrado := (BusquedaFuerzaBruta(textoSeleccionado, palabraBuscada) > 0);
      '2': encontrado := (BusquedaBoyerMoore(textoSeleccionado, palabraBuscada) > 0);
      '3': encontrado := (BusquedaKMP(textoSeleccionado, palabraBuscada) > 0);
    else
      writeln('Algoritmo de busqueda inválido.');
      writeln;
      write('Presione cualquier tecla para continuar...');
      readkey;
      Exit;
    end;
    
    // Obtener el tiempo de fin de la búsqueda
    fin := Now;
    
    // Calcular la duración en milisegundos
    duracion := MilliSecondsBetween(inicio, fin);


    // Mostrar el resultado de la búsqueda
    if encontrado then
      begin
      writeln('La palabra "', palabraBuscada, '" fue encontrada en el texto.');
      writeln;
      
      cantidad := CantidadApariciones(textoSeleccionado, palabraBuscada);
      writeln('Opciones:');
      writeln('1. Ver cantidad de apariciones');
      writeln('2. Ver apariciones');
      
      write('Seleccione una opcion: ');
      readln(eleccion);
      // Verificar la opción seleccionada
      cantidad := CantidadApariciones(textoSeleccionado, palabraBuscada);
      if eleccion = 1 then
        begin
        // Calcular la cantidad de apariciones
        writeln('Cantidad de apariciones: ', cantidad);
        end
      else if eleccion = 2 then
        begin
        // Mostrar contextos
        VerApariciones(textoSeleccionado, palabraBuscada);
        end
      else
        begin
        writeln('Opcion invalida.');
        end;

        //Agregar la información al historial
        agregarAlHistorial(opcion, palabraBuscada, duracion, cantidad);
      end
    else
      begin
      writeln('La palabra "', palabraBuscada, '" no fue encontrada en el texto.');
      end;
    writeln;
  end;



procedure VerHistorial;
  var
    i: Integer;
  begin
    clrscr;
    writeln('=== HISTORIAL DE BUSQUEDAS ===');
    writeln;

    if Length(Historial) = 0 then
    begin
      writeln('No se han realizado busquedas aun.');
    end
    else
    begin
      for i := 0 to Length(Historial) - 1 do
      begin
        writeln('Busqueda ', i + 1, ':');
        writeln('Texto elegido: ', Historial[i].TextoElegido);
        writeln('Texto buscado: ', Historial[i].TextoBuscado);
        writeln('Tiempo de busqueda: ', FormatFloat('0.00', Historial[i].TiempoBusqueda), ' ms');
        writeln('Cantidad de apariciones: ', Historial[i].CantidadApariciones);
        writeln;
      end;
    end;

    writeln;
  end;


procedure IngresoSistema;
    var
    usuario, contrasena: string;
    i: Integer;
    usuarioValido: Boolean;
    begin
    clrscr; // Limpiar la pantalla
    writeln('=== INGRESO AL SISTEMA ===');

    // Llamada a la función de inicialización de usuarios y contraseñas
    InicializarUsuarios;

    repeat
        usuarioValido := False;
        writeln('Usuario: ');
        readln(usuario);
        writeln('Contrasena: ');
        readln(contrasena);

        for i := 1 to MAX_USUARIOS do
        begin
        if (Usuarios[i].Nombre = usuario) and (Usuarios[i].Contrasena = contrasena) then
        begin
            usuarioValido := True;
            Break;
        end;
        end;

        if usuarioValido then
        begin
        writeln('Acceso concedido. Bienvenido, ', usuario);
        writeln;
        write('Presiona cualquier tecla para continuar...');
        readkey;

        repeat
            clrscr; // Limpiar la pantalla

            writeln('=== MENU PRINCIPAL ===');
            writeln('1. Registrar Texto');
            writeln('2. Buscar Texto');
            writeln('3. Ver Historial');
            writeln('0. Salir');
            writeln;

            write('Selecciona una opcion: ');
            readln(i);

            case i of
            1: RegistrarTexto;
            2: BuscarTexto;
            3: VerHistorial;
            // Resto de los casos
            0:
            begin
                writeln('Saliendo del programa...');
                Exit; // Salimos del programa después de seleccionar la opción 0
            end;
            else
            writeln('Opcion invalida');
            end;

            writeln;
            write('Presiona cualquier tecla para continuar...');
            readkey;
        until i = 0;
        end
        else
        begin
        writeln('Acceso denegado. Usuario o contrasena incorrectos.');
        writeln;
        write('Presiona cualquier tecla para continuar...');
        readkey;
        Exit; // Salimos del programa después de mostrar el mensaje de error
        end;
    until False;
    end;


begin
  TextosCargados := TStringList.Create; // Crear instancia de TStringList para almacenar los textos
  IngresoSistema;
  TextosCargados.Free; // Liberar la memoria utilizada por la variable Textos
end.
