// BORRADOR · pendiente de revisión por una persona hablante nativa (tarea P-07).
//
// Criterios de este borrador:
// - español neutro: se evitan regionalismos marcados (palta, frutilla, choclo…);
// - sin palabras con doble sentido vulgar en algún país (concha, almeja,
//   polla, paja, pico, papaya, huevo, cola…);
// - una sola palabra, sin espacios ni guiones; entre 3 y 14 letras.
// La grilla usa la forma normalizada (sin tildes, con Ñ); la lista muestra
// esta ortografía.
import 'word_theme.dart';

const spanishThemes = <WordTheme>[
  WordTheme('frutas', 'Frutas', [
    'aguacate', 'albaricoque', 'arándano', 'banana', 'cereza', 'chirimoya', 'ciruela', 'coco', 'dátil', //
    'durazno', 'frambuesa', 'fresa', 'granada', 'grosella', 'guanábana', 'guayaba', 'higo', 'kiwi', 'lima',
    'limón', 'lichi', 'mandarina', 'mango', 'manzana', 'maracuyá', 'melocotón', 'melón', 'membrillo', 'mora',
    'naranja', 'níspero', 'nectarina', 'pera', 'piña', 'pitahaya', 'plátano', 'pomelo', 'sandía', 'tamarindo',
    'toronja', 'uva', 'zarzamora', 'carambola', 'mamey', 'caqui', 'almendra', 'avellana', 'castaña', 'nuez',
    'pistacho', 'anacardo', 'bellota', 'piñón', 'pasa', 'granadilla', 'guinda', 'mangostán', 'acerola',
    'rambután',
  ]),
  WordTheme('verduras', 'Verduras y hortalizas', [
    'acelga', 'ajo', 'alcachofa', 'apio', 'berenjena', 'berro', 'brócoli', 'calabacín', 'calabaza', 'cebolla', //
    'cebollino', 'coliflor', 'col', 'espárrago', 'espinaca', 'guisante', 'haba', 'lechuga', 'lenteja',
    'garbanzo', 'maíz', 'nabo', 'patata', 'papa', 'pepino', 'perejil', 'pimiento', 'puerro', 'rábano',
    'remolacha', 'repollo', 'rúcula', 'tomate', 'zanahoria', 'alubia', 'alcaparra', 'berza', 'boniato',
    'batata', 'champiñón', 'seta', 'endibia', 'escarola', 'hinojo', 'jengibre', 'okra', 'soja', 'chalota',
    'chirivía', 'colinabo', 'cardo', 'yuca', 'ñame', 'albahaca', 'cilantro', 'orégano', 'romero', 'tomillo',
    'menta', 'laurel', 'eneldo',
  ]),
  WordTheme('granja', 'La granja', [
    'vaca', 'toro', 'ternero', 'buey', 'caballo', 'yegua', 'potro', 'burro', 'asno', 'mula', 'oveja', //
    'cordero', 'carnero', 'cabra', 'chivo', 'cerdo', 'lechón', 'gallina', 'gallo', 'pollito', 'pato', 'ganso',
    'oca', 'pavo', 'conejo', 'perro', 'gato', 'codorniz', 'paloma', 'abeja', 'alpaca', 'llama', 'búfalo',
    'poni', 'rebaño', 'establo', 'granero', 'corral', 'pastor', 'granjero', 'tractor', 'heno', 'pienso',
    'abrevadero', 'molino', 'huerto', 'silo', 'ordeño', 'leche', 'queso', 'lana', 'estiércol', 'arado',
    'surco', 'cosecha', 'trigo', 'cebada', 'avena', 'centeno', 'espantapájaros', 'pocilga', 'gallinero',
    'cuadra', 'montura', 'herradura',
  ]),
  WordTheme('salvajes', 'Animales salvajes', [
    'león', 'tigre', 'elefante', 'jirafa', 'cebra', 'rinoceronte', 'hipopótamo', 'gorila', 'chimpancé', //
    'orangután', 'mono', 'leopardo', 'guepardo', 'jaguar', 'puma', 'pantera', 'lince', 'lobo', 'zorro', 'oso',
    'panda', 'koala', 'canguro', 'camello', 'dromedario', 'ciervo', 'alce', 'reno', 'gacela', 'antílope',
    'bisonte', 'jabalí', 'hiena', 'chacal', 'mapache', 'castor', 'nutria', 'ardilla', 'erizo', 'topo', 'tejón',
    'armadillo', 'perezoso', 'tapir', 'okapi', 'suricata', 'mangosta', 'comadreja', 'hurón', 'liebre',
    'murciélago', 'cocodrilo', 'caimán', 'serpiente', 'cobra', 'pitón', 'boa', 'iguana', 'camaleón', 'tortuga',
    'lagarto', 'rana', 'sapo', 'salamandra', 'víbora', 'coyote', 'ocelote', 'marmota', 'chinchilla',
  ]),
  WordTheme('aves', 'Aves', [
    'águila', 'halcón', 'búho', 'lechuza', 'cóndor', 'buitre', 'gavilán', 'cuervo', 'urraca', 'gorrión', //
    'golondrina', 'canario', 'jilguero', 'ruiseñor', 'mirlo', 'petirrojo', 'colibrí', 'loro', 'cotorra',
    'guacamayo', 'tucán', 'pelícano', 'gaviota', 'albatros', 'flamenco', 'cigüeña', 'garza', 'grulla',
    'pingüino', 'avestruz', 'emú', 'ñandú', 'faisán', 'perdiz', 'codorniz', 'paloma', 'tórtola', 'cisne',
    'pato', 'ganso', 'gallina', 'pavo', 'abubilla', 'alondra', 'vencejo', 'estornino', 'cormorán',
    'frailecillo', 'quetzal', 'cacatúa', 'periquito', 'kiwi', 'milano', 'azor', 'cernícalo', 'chorlito', 'grajo',
    'arrendajo', 'oropéndola', 'martinete', 'pardillo', 'verderón', 'carbonero', 'mochuelo',
  ]),
  WordTheme('mar', 'El mar', [
    'ballena', 'delfín', 'tiburón', 'orca', 'morsa', 'pulpo', 'calamar', 'sepia', 'medusa', 'cangrejo', //
    'langosta', 'gamba', 'camarón', 'langostino', 'mejillón', 'ostra', 'caracol', 'erizo', 'coral', 'esponja',
    'anémona', 'pez', 'atún', 'sardina', 'salmón', 'bacalao', 'merluza', 'anguila', 'raya', 'mantarraya',
    'dorado', 'besugo', 'lubina', 'rodaballo', 'lenguado', 'mero', 'pargo', 'jurel', 'caballa', 'anchoa',
    'boquerón', 'arenque', 'bonito', 'marlín', 'barracuda', 'morena', 'tortuga', 'nutria', 'manatí', 'narval',
    'cachalote', 'krill', 'plancton', 'alga', 'arrecife', 'ola', 'marea', 'playa', 'arena', 'orilla', 'faro',
    'puerto', 'gaviota', 'percebe', 'navaja',
  ]),
  WordTheme('insectos', 'Insectos', [
    'hormiga', 'abeja', 'avispa', 'abejorro', 'mosca', 'mosquito', 'mariposa', 'polilla', 'libélula', //
    'saltamontes', 'grillo', 'chicharra', 'cigarra', 'escarabajo', 'mariquita', 'luciérnaga', 'cucaracha',
    'termita', 'pulga', 'piojo', 'chinche', 'garrapata', 'araña', 'escorpión', 'alacrán', 'ciempiés', 'milpiés',
    'lombriz', 'caracol', 'babosa', 'oruga', 'gusano', 'larva', 'crisálida', 'capullo', 'colmena', 'panal',
    'hormiguero', 'mantis', 'tijereta', 'gorgojo', 'avispón', 'tábano', 'efímera', 'cochinilla', 'pulgón',
    'langosta', 'ácaro', 'tarántula', 'telaraña', 'antena', 'ala', 'aguijón', 'néctar', 'polen', 'enjambre',
    'zángano', 'obrera', 'metamorfosis', 'insecto',
  ]),
  WordTheme('cocina', 'Utensilios de cocina', [
    'cuchara', 'cuchillo', 'tenedor', 'plato', 'vaso', 'taza', 'tazón', 'olla', 'sartén', 'cacerola', 'cazo', //
    'cazuela', 'tetera', 'cafetera', 'jarra', 'botella', 'colador', 'embudo', 'rallador', 'batidora',
    'licuadora', 'tostadora', 'horno', 'microondas', 'nevera', 'refrigerador', 'congelador', 'fregadero',
    'grifo', 'estufa', 'fogón', 'parrilla', 'plancha', 'bandeja', 'fuente', 'tabla', 'rodillo', 'espátula',
    'cucharón', 'pinzas', 'tijeras', 'abrelatas', 'sacacorchos', 'servilleta', 'mantel', 'delantal', 'molde',
    'termo', 'cuenco', 'mortero', 'balanza', 'especiero', 'salero', 'pimentero', 'azucarera', 'panera',
    'frutero', 'aceitera', 'lavavajillas', 'escurridor', 'cubiertos', 'vajilla', 'copa', 'platillo',
    'sopera', 'paellera', 'exprimidor',
  ]),
  WordTheme('comidas', 'Comidas', [
    'pan', 'arroz', 'pasta', 'sopa', 'ensalada', 'tortilla', 'empanada', 'pizza', 'hamburguesa', 'sándwich', //
    'bocadillo', 'taco', 'burrito', 'tamal', 'arepa', 'paella', 'lasaña', 'espagueti', 'macarrones',
    'croqueta', 'albóndiga', 'guiso', 'estofado', 'puré', 'crema', 'caldo', 'cocido', 'filete', 'chuleta',
    'pollo', 'pescado', 'marisco', 'jamón', 'queso', 'mantequilla', 'yogur', 'galleta', 'pastel', 'tarta',
    'bizcocho', 'flan', 'helado', 'chocolate', 'caramelo', 'mermelada', 'miel', 'cereal', 'avena', 'granola',
    'panqueque', 'gofre', 'churro', 'magdalena', 'rosquilla', 'natilla', 'gelatina', 'compota', 'batido',
    'zumo', 'jugo', 'café', 'infusión', 'ceviche', 'gazpacho', 'fajita', 'quesadilla', 'enchilada', 'pozole',
    'salsa', 'aderezo',
  ]),
  WordTheme('profesiones', 'Profesiones', [
    'médico', 'dentista', 'periodista', 'artista', 'electricista', 'taxista', 'recepcionista', 'piloto', //
    'policía', 'juez', 'chef', 'guía', 'intérprete', 'cantante', 'agente', 'docente', 'gerente', 'maestro',
    'profesor', 'abogado', 'ingeniero', 'arquitecto', 'bombero', 'carpintero', 'albañil', 'fontanero',
    'plomero', 'mecánico', 'panadero', 'carnicero', 'pescadero', 'agricultor', 'ganadero', 'cocinero',
    'camarero', 'mesero', 'cartero', 'conductor', 'astronauta', 'científico', 'químico', 'biólogo',
    'veterinario', 'farmacéutico', 'psicólogo', 'contador', 'economista', 'programador', 'diseñador',
    'fotógrafo', 'pintor', 'escultor', 'escritor', 'poeta', 'actor', 'músico', 'bailarín', 'peluquero',
    'barbero', 'sastre', 'zapatero', 'joyero', 'relojero', 'jardinero', 'florista', 'bibliotecario',
    'traductor', 'marinero', 'pescador', 'minero', 'leñador', 'cajero', 'vendedor', 'secretario', 'enfermero',
  ]),
  WordTheme('deportes', 'Deportes', [
    'fútbol', 'baloncesto', 'béisbol', 'tenis', 'voleibol', 'balonmano', 'rugby', 'golf', 'hockey', 'boxeo', //
    'judo', 'kárate', 'taekwondo', 'esgrima', 'natación', 'buceo', 'surf', 'remo', 'vela', 'piragüismo',
    'ciclismo', 'atletismo', 'maratón', 'triatlón', 'gimnasia', 'patinaje', 'esquí', 'escalada', 'alpinismo',
    'senderismo', 'equitación', 'polo', 'críquet', 'bádminton', 'squash', 'pádel', 'frontón', 'billar',
    'bolos', 'ajedrez', 'dardos', 'tiro', 'halterofilia', 'lucha', 'karting', 'motociclismo', 'pelota', 'balón',
    'raqueta', 'red', 'portería', 'gol', 'árbitro', 'estadio', 'cancha', 'medalla', 'trofeo', 'equipo',
    'jugador', 'entrenador', 'carrera', 'salto', 'jabalina', 'disco', 'relevo', 'vallas',
  ]),
  WordTheme('musica', 'Música', [
    'guitarra', 'piano', 'violín', 'viola', 'violonchelo', 'contrabajo', 'arpa', 'flauta', 'clarinete', 'oboe', //
    'fagot', 'saxofón', 'trompeta', 'trombón', 'tuba', 'trompa', 'batería', 'tambor', 'bombo', 'timbal',
    'platillo', 'xilófono', 'marimba', 'maracas', 'pandereta', 'castañuelas', 'triángulo', 'acordeón',
    'armónica', 'órgano', 'teclado', 'sintetizador', 'bajo', 'ukelele', 'banjo', 'mandolina', 'laúd',
    'charango', 'bandoneón', 'gaita', 'quena', 'zampoña', 'cajón', 'güiro', 'bongó', 'conga', 'campana',
    'cascabel', 'silbato', 'ocarina', 'melodía', 'ritmo', 'armonía', 'nota', 'acorde', 'partitura', 'canción',
    'orquesta', 'banda', 'coro', 'concierto', 'director', 'compás', 'pentagrama', 'clave',
  ]),
  WordTheme('ropa', 'Ropa y accesorios', [
    'camisa', 'camiseta', 'blusa', 'pantalón', 'falda', 'vestido', 'chaqueta', 'abrigo', 'chaleco', 'suéter', //
    'jersey', 'sudadera', 'bufanda', 'guante', 'gorro', 'sombrero', 'gorra', 'boina', 'calcetín', 'media',
    'zapato', 'zapatilla', 'bota', 'sandalia', 'chancla', 'pijama', 'bata', 'bañador', 'bikini', 'corbata',
    'cinturón', 'tirantes', 'pañuelo', 'bolso', 'mochila', 'cartera', 'billetera', 'reloj', 'pulsera',
    'collar', 'anillo', 'pendiente', 'arete', 'gafas', 'anteojos', 'paraguas', 'impermeable', 'uniforme',
    'traje', 'esmoquin', 'peto', 'capa', 'poncho', 'kimono', 'túnica', 'leotardo', 'chándal', 'bermuda',
    'botón', 'cremallera', 'bolsillo', 'cuello', 'manga',
  ]),
  WordTheme('casa', 'La casa', [
    'puerta', 'ventana', 'techo', 'tejado', 'pared', 'suelo', 'piso', 'escalera', 'pasillo', 'cocina', //
    'salón', 'comedor', 'dormitorio', 'baño', 'ducha', 'bañera', 'lavabo', 'espejo', 'armario', 'cajón',
    'estante', 'estantería', 'mesa', 'silla', 'sofá', 'sillón', 'cama', 'almohada', 'sábana', 'manta',
    'colchón', 'cortina', 'alfombra', 'lámpara', 'sótano', 'ático', 'desván', 'garaje', 'jardín', 'terraza',
    'balcón', 'chimenea', 'timbre', 'buzón', 'llave', 'cerradura', 'picaporte', 'enchufe', 'interruptor',
    'bombilla', 'persiana', 'radiador', 'calefacción', 'ventilador', 'cuna', 'cómoda', 'mesilla', 'perchero',
    'florero', 'cuadro', 'felpudo', 'patio', 'tapete', 'recibidor',
  ]),
  WordTheme('herramientas', 'Herramientas', [
    'martillo', 'clavo', 'tornillo', 'tuerca', 'destornillador', 'llave', 'alicate', 'tenazas', 'sierra', //
    'serrucho', 'taladro', 'broca', 'lija', 'cepillo', 'cincel', 'formón', 'escuadra', 'nivel', 'metro',
    'cinta', 'regla', 'compás', 'pala', 'rastrillo', 'azada', 'hacha', 'machete', 'tijeras', 'podadora',
    'cortacésped', 'carretilla', 'escalera', 'andamio', 'paleta', 'llana', 'brocha', 'rodillo', 'pincel',
    'pegamento', 'clavija', 'bisagra', 'perno', 'arandela', 'grapa', 'grapadora', 'soldador', 'linterna',
    'manguera', 'cubo', 'balde', 'cuerda', 'polea', 'palanca', 'mazo', 'maza', 'lima', 'escofina', 'punzón',
    'torno', 'yunque', 'fragua', 'gubia',
  ]),
  WordTheme('transportes', 'Transportes', [
    'coche', 'auto', 'automóvil', 'camión', 'autobús', 'furgoneta', 'camioneta', 'taxi', 'moto', //
    'motocicleta', 'bicicleta', 'patinete', 'monopatín', 'tren', 'metro', 'tranvía', 'teleférico', 'funicular',
    'avión', 'avioneta', 'helicóptero', 'globo', 'dirigible', 'cohete', 'nave', 'barco', 'bote', 'lancha',
    'velero', 'yate', 'crucero', 'ferry', 'canoa', 'kayak', 'balsa', 'submarino', 'trasatlántico', 'carguero',
    'remolcador', 'tractor', 'ambulancia', 'grúa', 'excavadora', 'carruaje', 'carreta', 'trineo', 'caravana',
    'limusina', 'todoterreno', 'triciclo', 'hidroavión', 'góndola', 'piragua', 'catamarán', 'telesilla',
    'locomotora', 'vagón', 'diligencia', 'aerodeslizador',
  ]),
  WordTheme('naturaleza', 'Paisajes y naturaleza', [
    'montaña', 'colina', 'valle', 'río', 'lago', 'laguna', 'mar', 'océano', 'playa', 'costa', 'isla', //
    'península', 'bahía', 'golfo', 'cabo', 'acantilado', 'cueva', 'gruta', 'volcán', 'cráter', 'glaciar',
    'desierto', 'duna', 'oasis', 'selva', 'bosque', 'jungla', 'pradera', 'llanura', 'meseta', 'sabana', 'tundra',
    'estepa', 'pantano', 'ciénaga', 'manantial', 'cascada', 'catarata', 'arroyo', 'riachuelo', 'cañón',
    'barranco', 'cordillera', 'cumbre', 'cima', 'ladera', 'roca', 'piedra', 'arena', 'tierra', 'barro', 'musgo',
    'helecho', 'raíz', 'hoja', 'rama', 'tronco', 'arrecife', 'delta', 'estuario', 'fiordo', 'géiser',
    'archipiélago', 'horizonte', 'paisaje',
  ]),
  WordTheme('clima', 'El tiempo y el clima', [
    'sol', 'lluvia', 'nube', 'viento', 'nieve', 'granizo', 'niebla', 'neblina', 'rocío', 'escarcha', 'hielo', //
    'tormenta', 'trueno', 'relámpago', 'rayo', 'huracán', 'tornado', 'ciclón', 'tifón', 'monzón', 'ventisca',
    'brisa', 'ráfaga', 'chubasco', 'aguacero', 'llovizna', 'diluvio', 'sequía', 'inundación', 'calor', 'frío',
    'temperatura', 'humedad', 'presión', 'termómetro', 'barómetro', 'veleta', 'pronóstico', 'estación',
    'primavera', 'verano', 'otoño', 'invierno', 'arcoíris', 'aurora', 'eclipse', 'amanecer', 'atardecer',
    'crepúsculo', 'nublado', 'soleado', 'lluvioso', 'despejado', 'templado', 'helada', 'deshielo',
    'bochorno', 'polvareda', 'tempestad', 'clima',
  ]),
  WordTheme('cuerpo', 'El cuerpo humano', [
    'cabeza', 'cara', 'frente', 'ceja', 'pestaña', 'ojo', 'nariz', 'boca', 'labio', 'diente', 'lengua', 'oreja', //
    'mejilla', 'barbilla', 'mentón', 'cuello', 'hombro', 'brazo', 'codo', 'muñeca', 'mano', 'dedo', 'uña',
    'pulgar', 'pecho', 'espalda', 'cintura', 'cadera', 'pierna', 'rodilla', 'tobillo', 'pie', 'talón',
    'corazón', 'pulmón', 'hígado', 'riñón', 'estómago', 'cerebro', 'hueso', 'músculo', 'piel', 'sangre', 'vena',
    'arteria', 'esqueleto', 'cráneo', 'columna', 'costilla', 'garganta', 'ombligo', 'pelo', 'cabello',
    'mandíbula', 'nuca', 'palma', 'muslo', 'pantorrilla', 'esófago', 'intestino', 'tendón', 'neurona',
    'párpado',
  ]),
  WordTheme('colores', 'Colores', [
    'rojo', 'azul', 'verde', 'amarillo', 'naranja', 'morado', 'violeta', 'rosa', 'rosado', 'blanco', 'negro', //
    'gris', 'marrón', 'café', 'beige', 'dorado', 'plateado', 'celeste', 'turquesa', 'granate', 'añil',
    'índigo', 'lila', 'magenta', 'fucsia', 'ocre', 'crema', 'carmesí', 'bermellón', 'esmeralda', 'coral',
    'salmón', 'cian', 'ámbar', 'marfil', 'oliva', 'caqui', 'burdeos', 'púrpura', 'escarlata', 'cobre',
    'bronce', 'perla', 'lavanda', 'malva', 'mostaza', 'caramelo', 'chocolate', 'vainilla', 'menta',
    'aguamarina', 'zafiro', 'rubí', 'grana', 'siena', 'sepia', 'terracota', 'ceniza', 'nácar', 'azabache',
    'carbón', 'arena', 'canela',
  ]),
];

/// Palabras que la grilla nunca debe formar por su cuenta (relleno o cruces).
/// Forma normalizada o no: el motor las normaliza.
const spanishBlocklist = <String>{
  'puta', 'puto', 'putas', 'putos', 'mierda', 'culo', 'culos', 'coño', 'polla', 'pene', 'verga', 'pija', //
  'concha', 'chucha', 'caca', 'pedo', 'teta', 'tetas', 'cabrón', 'cabrona', 'marica', 'maricón', 'joto',
  'zorra', 'chocho', 'cagar', 'cagada', 'mear', 'follar', 'cojones', 'joder', 'jodido', 'paja', 'pajero',
  'picha', 'pico', 'orto', 'ojete', 'gilipollas', 'subnormal', 'nazi', 'malparido', 'pendejo', 'culiao',
  'chingar', 'chingada', 'violar', 'porno', 'sexo', 'anal', 'mamada', 'huevón', 'hostia',
};
