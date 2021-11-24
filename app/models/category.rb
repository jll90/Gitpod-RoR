class Category < ApplicationRecord

  has_many :categorizations
  has_many :products, through: :categorizations

  def self.base_names 
    [
      'Cámaras y Fotografía',
      'PC & Notebooks',
      'Moda',
      'Celulares',
      'Vehículos',
      'Motocicletas',
      'Deportes',
      'Ciclismo',
      'Trekking & Camping',
      'TV, Audio & Video',
      'Videojuegos & Consolas',
      'Electrónica',
      'Entretención y Ocio',
      'Hogar & Jardín',
      'Películas',
      'Música',
      'Libros y Comics',
      'Arte & Coleccionables',
      'Otros'
    ]
  end

  def self.seed!
    self.base_names.map do |name|
      Category.create!(name: name)
    end
  end
end
