import UIKit
import AVFoundation

class JuegoViewController: UIViewController {
    @IBOutlet weak var numeroIntentoLabel: UILabel!
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var puntosLabel: UILabel!
    @IBOutlet weak var vidasLabel: UILabel!
    @IBOutlet weak var rondaLabel: UILabel!
    
    var palabrasPosibles = [
        "PERRO", "GATOS", "SALTO", "LLAVE", "MANGO", "ROSAS", "LIMON", "NUBES", "LUCES", "BRISA", "HOJAS", "BOTAS", "AVION", "PASTO", "NARIZ", "TAZAS", "CAMPO", "DIANA", "RELOJ", "CIELO", "CANTO", "REINA", "MONTO", "GOLPE", "CREMA", "PANAL", "TELAR", "MOTOR", "SILLA", "CASAS"
    ]
    
    var palabraSecreta: String = ""
    var cuadros: [[UILabel]] = []
    let filas = 6
    let columnas = 5
    var intentoActual = 0
    var posicionActual = 0
    var segundosTranscurridos = 0
    var timer: Timer?
    var ronda = 1
    var vidas = 3
    var puntajeTotal = 0
    var reproductorSonido: AVAudioPlayer?
    var letrasIncorrectas: Set<String> = []
    var musicaDeFondoPlayer: AVAudioPlayer?


    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurarAudioSession()
        reproducirMusicaDeFondo()

        // Ahora que la música ya empezó (o no), podemos configurar el botón con el ícono correcto
        let icono = UIImage(systemName: musicaDeFondoPlayer?.isPlaying == true ? "speaker.fill" : "speaker.slash.fill")
        let botonSonido = UIBarButtonItem(image: icono, style: .plain, target: self, action: #selector(alternarSonido))
        
        // (verde #709D62)
        botonSonido.tintColor = UIColor(red: 112/255, green: 157/255, blue: 98/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor(red: 112/255, green: 157/255, blue: 98/255, alpha: 1.0)
        navigationItem.rightBarButtonItem = botonSonido

        
        NotificationCenter.default.addObserver(self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        palabraSecreta = palabrasPosibles.randomElement() ?? "ERROR"
        print("Palabra secreta: \(palabraSecreta)")
        actualizarNumeroIntentoLabel()
        actualizarVidasYRonda()
        iniciarTimer()
        reproducirMusicaDeFondo()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if cuadros.isEmpty {
            generarCuadricula()
        }
        generarTeclado()
    }

    func generarCuadricula() {
        let anchoCuadro: CGFloat = 50
        let espacio: CGFloat = 8
        let inicioX = (view.frame.width - (CGFloat(columnas) * (anchoCuadro + espacio) - espacio)) / 2
        let inicioY: CGFloat = tiempoLabel.frame.maxY + 10

        for fila in 0..<filas {
            var filaCuadros: [UILabel] = []
            for columna in 0..<columnas {
                let cuadro = UILabel()
                cuadro.frame = CGRect(
                    x: inicioX + CGFloat(columna) * (anchoCuadro + espacio),
                    y: inicioY + CGFloat(fila) * (anchoCuadro + espacio),
                    width: anchoCuadro,
                    height: anchoCuadro
                )
                cuadro.textAlignment = .center
                cuadro.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                cuadro.layer.borderWidth = 2
                cuadro.layer.borderColor = UIColor.gray.cgColor
                cuadro.backgroundColor = .darkGray
                cuadro.textColor = .white
                view.addSubview(cuadro)
                filaCuadros.append(cuadro)
            }
            cuadros.append(filaCuadros)
        }
    }

    func generarTeclado() {
        let teclas = [
            "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
            "A", "S", "D", "F", "G", "H", "J", "K", "L",
            "Z", "X", "C", "V", "B", "N", "M"
        ]

        let anchoTecla: CGFloat = 37
        let altoTecla: CGFloat = 50
        let espacio: CGFloat = 2
        let inicioY = (cuadros.last?.first?.frame.maxY ?? 0) + 40
        let anchoTotal = view.frame.width

        var filaActual = 0
        var xPos: CGFloat = 0

        let filasTeclado = [
            Array(teclas[0..<10]),
            Array(teclas[10..<19]),
            Array(teclas[19..<26])
        ]

        for fila in filasTeclado {
            xPos = (anchoTotal - (CGFloat(fila.count) * (anchoTecla + espacio) - espacio)) / 2
            for letra in fila {
                let tecla = UIButton(type: .system)
                tecla.frame = CGRect(
                    x: xPos,
                    y: inicioY + CGFloat(filaActual) * (altoTecla + espacio),
                    width: anchoTecla,
                    height: altoTecla
                )
                tecla.setTitle(letra, for: .normal)
                tecla.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                tecla.backgroundColor = UIColor.darkGray
                tecla.tintColor = UIColor.green
                tecla.layer.cornerRadius = 5
                tecla.addTarget(self, action: #selector(teclaPresionada(_:)), for: .touchUpInside)
                view.addSubview(tecla)
                if letrasIncorrectas.contains(letra) {
                    tecla.isEnabled = false
                    tecla.backgroundColor = .gray
                    tecla.tintColor = .lightGray
                }

                xPos += anchoTecla + espacio
            }
            filaActual += 1
        }

        let borrarTecla = UIButton(type: .system)
        borrarTecla.frame = CGRect(
            x: (anchoTotal / 2) - 70,
            y: inicioY + CGFloat(filaActual) * (altoTecla + espacio),
            width: 60,
            height: altoTecla
        )
        borrarTecla.setTitle("⌫", for: .normal)
        borrarTecla.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        borrarTecla.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        borrarTecla.tintColor = .white
        borrarTecla.layer.cornerRadius = 5
        borrarTecla.addTarget(self, action: #selector(borrarLetraPressed), for: .touchUpInside)
        view.addSubview(borrarTecla)

        let enviarTecla = UIButton(type: .system)
        enviarTecla.frame = CGRect(
            x: (anchoTotal / 2) + 10,
            y: borrarTecla.frame.origin.y,
            width: 60,
            height: altoTecla
        )
        enviarTecla.setTitle("ENTER", for: .normal)
        enviarTecla.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        enviarTecla.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        enviarTecla.tintColor = .white
        enviarTecla.layer.cornerRadius = 5
        enviarTecla.addTarget(self, action: #selector(enviarPalabraPressed), for: .touchUpInside)
        view.addSubview(enviarTecla)
    }

    @objc func teclaPresionada(_ sender: UIButton) {
        guard let letra = sender.titleLabel?.text else { return }
        if posicionActual < columnas && intentoActual < filas {
            cuadros[intentoActual][posicionActual].text = letra
            posicionActual += 1
        }
    }

    @objc func borrarLetraPressed() {
        if posicionActual > 0 {
            posicionActual -= 1
            cuadros[intentoActual][posicionActual].text = ""
        }
    }

    @objc func enviarPalabraPressed() {
        if posicionActual < columnas { return }

        let palabraIntento = cuadros[intentoActual].compactMap { $0.text }.joined()
        validarIntento(palabraIntento)
        if palabraIntento == palabraSecreta {
            reproducirSonido()
            mostrarAlerta(titulo: "¡Bien!", mensaje: "Adivinaste la palabra. Pasas a la ronda \(ronda + 1)") {
                self.ronda += 1
                self.iniciarRonda()
            }
            return
        }

        intentoActual += 1
        posicionActual = 0

        if intentoActual == filas {
            vidas -= 1
            if vidas == 0 {
                timer?.invalidate()
                mostrarAlerta(titulo: "Perdiste", mensaje: "Te quedaste sin vidas.\nLa palabra era: \(palabraSecreta)"){
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                mostrarAlerta(titulo: "No adivinaste", mensaje: "La palabra era: \(palabraSecreta). Pasa a la ronda \(ronda + 1)"){
                    self.ronda += 1
                    self.iniciarRonda()
                }
            }
            return
        }
        
        if intentoActual != filas {
            actualizarNumeroIntentoLabel()
        }
    }

    func validarIntento(_ palabraIntento: String) {
        print("Validando intento: \(palabraIntento)")
        
        let letrasSecreta = Array(palabraSecreta)
        let letrasIntento = Array(palabraIntento)

        var resultado: [UIColor] = Array(repeating: .darkGray, count: columnas)
        var usadaEnSecreta = Array(repeating: false, count: columnas)

        for i in 0..<columnas {
            if letrasIntento[i] == letrasSecreta[i] {
                resultado[i] = .green
                usadaEnSecreta[i] = true
            }
        }

        for i in 0..<columnas {
            if resultado[i] == .green { continue }

            for j in 0..<columnas {
                if !usadaEnSecreta[j], letrasIntento[i] == letrasSecreta[j] {
                    resultado[i] = .systemYellow
                    usadaEnSecreta[j] = true
                    break
                }
            }
        }

        for i in 0..<columnas {
            let cuadro = cuadros[intentoActual][i]
            print("Letra: \(cuadro.text ?? "_") → \(resultado[i])")

            DispatchQueue.main.async {
                cuadro.backgroundColor = resultado[i]
                if resultado[i] == .darkGray {
                    if let letra = cuadro.text {
                        self.letrasIncorrectas.insert(letra)
                        self.desactivarTecla(letra)
                    }
                }
                cuadro.textColor = .white
                cuadro.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func desactivarTecla(_ letra: String) {
        for subvista in view.subviews {
            if let boton = subvista as? UIButton,
               boton.title(for: .normal) == letra {
                boton.isEnabled = false
                boton.backgroundColor = .gray
                boton.tintColor = .lightGray
            }
        }
    }


    func mostrarAlerta(titulo: String, mensaje: String, alAceptar: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alAceptar?()
        })
        present(alerta, animated: true)
    }

    func actualizarNumeroIntentoLabel() {
        numeroIntentoLabel.text = "Intento \(intentoActual + 1) de \(filas)"
    }
    
    func iniciarTimer() {
        segundosTranscurridos = 0
        actualizarTiempo()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.segundosTranscurridos += 1
            self.actualizarTiempo()
            
        }
        
    }
    func actualizarTiempo(){
        let minutos = segundosTranscurridos / 60
        let segundos = segundosTranscurridos % 60
        tiempoLabel.text = String(format: "%02d:%02d", minutos, segundos)
    }
    
    func iniciarRonda(){
        palabraSecreta = palabrasPosibles.randomElement() ?? "ERROR"
        intentoActual = 0
        posicionActual = 0
        limpiarCuadricula()
        generarCuadricula()
        actualizarNumeroIntentoLabel()
        actualizarVidasYRonda()
        letrasIncorrectas.removeAll()

    }
    
    func limpiarCuadricula() {
        for fila in cuadros {
            for cuadro in fila {
                cuadro.removeFromSuperview()
            }
        }
        cuadros.removeAll()
    }
    
    func actualizarVidasYRonda() {
        switch vidas  {
        case 3:
            vidasLabel.text = "❤️❤️❤️"
            break
        case 2:
            vidasLabel.text = "❤️❤️"
            break
        case 1:
            vidasLabel.text = "❤️"
            break
        default:
            vidasLabel.text = ""
            break
        }
        rondaLabel.text = "Ronda: \(ronda)"
        puntajeTotal = calcularPuntuaje()
        puntosLabel.text = "Puntos: \(puntajeTotal)" // o tu propio sistema
    }
    
    func calcularPuntuaje() -> Int {
        let vidasPerdidas = 3 - vidas
        let base = ronda * 100
        let bonificacionTiempo = max(0, 180 - segundosTranscurridos) // tiempo ideal: 3 min
        let penalizacion = vidasPerdidas * 50
        return base + bonificacionTiempo - penalizacion
    }
    func reproducirSonido(){
        guard let url = Bundle.main.url(forResource: "tiktok_pop_notification3_by_miraclei-360007", withExtension: "mp3") else {
            print("No se encontro el audio")
            return
        }
        do{
            reproductorSonido = try AVAudioPlayer(contentsOf: url)
            reproductorSonido?.prepareToPlay()
            reproductorSonido?.play()
        } catch {
            print("Error al reproducir sonido: \(error.localizedDescription)")
        }
    }
    
    func reproducirMusicaDeFondo() {
        guard let url = Bundle.main.url(forResource: "drown_converted", withExtension: "mp3") else {
            print("No se encontró la música de fondo")
            return
        }

        do {
            musicaDeFondoPlayer = try AVAudioPlayer(contentsOf: url)
            musicaDeFondoPlayer?.numberOfLoops = -1 // Repetir infinitamente
            musicaDeFondoPlayer?.volume = 0.3 // Volumen bajo
            musicaDeFondoPlayer?.play()
        } catch {
            print("Error al reproducir música de fondo: \(error.localizedDescription)")
        }
    }
    
    func configurarAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error al configurar la sesión de audio: \(error)")
        }
    }

    @objc func appWillResignActive() {
        musicaDeFondoPlayer?.pause()
    }

    @objc func appDidBecomeActive() {
        musicaDeFondoPlayer?.play()
    }
    
    @objc func alternarSonido() {
        guard let player = musicaDeFondoPlayer else { return }

        if player.isPlaying {
            player.pause()
            print("Sonido silenciado")
        } else {
            player.play()
            print("Sonido activado")
        }

        // Cambiar el ícono en la barra de navegación
        let nuevoIcono = UIImage(systemName: player.isPlaying ? "speaker.fill" : "speaker.slash.fill")
        navigationItem.rightBarButtonItem?.image = nuevoIcono
    }


}
