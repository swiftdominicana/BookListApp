import Foundation
import UIKit

// Clase que maneja el Cache de Imágenes
class ImageCache {
  // Instancimos el Cache utilizando la clase NSCache
  let memCache =  NSCache<NSString, UIImage>()
  // Creamos un Singleton
  static let shared = ImageCache()
  
  func imageWithURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
    // Verificamos si la imagen ya está en Cache, de ser asi retornamos la imagen en el Completion closure
    if let image = memCache.object(forKey: url.absoluteString as NSString) {
      completion(image)
      return
    }
    
    // Agregamos a la cola global, con prioridad userInteractive el código para buscar si la imagen existe en un directorio dentro del Sandbox del App
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      let fileManager = FileManager.default
      if let docs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
        //var c = fileManager.contentsOfDirectory(atPath: docs)
        let file = docs.appendingPathComponent(url.lastPathComponent)
        if let image = UIImage(contentsOfFile: file.path){
          // Retornamos la imagen en el Completion closure
          completion(image)
          
          // Guardamos la imagen en memoria, por si tenemos que utilizarla luego
          self?.saveInMemory(url: url, image: image)
          return
        }
      }
      
      // Si la imagen no estaba en memoria, ni en un directorio del Sandbox, procedemos a descargarla
      self?.downloadImage(url, completion: completion)
    }
  }
  
  // Guarda en memoria utilizando el objeto NSCache. Como key utilizaremoss el URL
  private func saveInMemory(url: URL, image: UIImage) {
    memCache.setObject(image, forKey: url.absoluteString as NSString)
  }
  
  // Descarga la imagen utilizando el URL
  private func downloadImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
    let session = URLSession.shared
    // Construimos la tarea utilizando el URL
    let task = session.dataTask(with: url) { [weak self] (data, response, error) in
      
      // Verificamos si ha ocurrido un error, o la data es nil.
      guard error == nil, data != nil  else {
        completion(nil)
        return
      }
      
      // Hacemos la conversión de la data retornada a UIImage
      if let image = UIImage(data: data!) {
        // Si se crea el objeto correctamente, retornamos la imagen en el completion closure
        completion(image)
        
        // Grabamos la imagen en memoria y en el directorio del Sandbox
        self?.saveInMemory(url: url, image: image)
        self?.saveInDirectory(url: url, image: image)
      }
      else {
        // Si la imagen no se pudo contruir retornamos nil en el completion closure
        completion(nil)
      }
    }
    //Ejecutamos la tarea
    task.resume()
  }
  
  // Guarda en un directorio físico dentro del sandbox del App
  private func saveInDirectory(url: URL, image: UIImage) {
    let fm = FileManager.default
    if let docs = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
      let file = docs.appendingPathComponent(url.lastPathComponent)
      if let data = image.pngData() {
        try? data.write(to: file)
      }
    }
  }
}

