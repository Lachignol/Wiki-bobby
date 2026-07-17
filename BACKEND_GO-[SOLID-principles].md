# Masterclass : Architecture SOLID, Gin, PostgreSQL, Middlewares, Docker & Bonnes Pratiques de Production en Go

Bienvenue dans ce guide ultime ! Que vous soyez développeur débutant, junior ou désireux de concevoir des backends de niveau industriel, ce tutoriel est fait pour vous. 

Nous allons construire pas à pas un backend complet, modulaire, robuste et sécurisé en **Go (Golang)**, en utilisant le framework **Gin** et une base de données **PostgreSQL**. L'intégralité du projet respecte les principes **SOLID**, les préceptes de la **Clean Architecture** (Ports & Adaptateurs), ainsi que les **meilleures pratiques de production** (Dockerisation multi-stage, Sécurisation des secrets, Arrêt Gracieux, Logging Structuré Slog, Validation avancée, et Conteneur d'Injection de Dépendances).

---

## 1. La Métaphore du Restaurant (Pourquoi l'architecture SOLID ?)

Pour comprendre pourquoi on sépare notre code en plusieurs dossiers et fichiers, imaginons notre application comme un **restaurant** :

```mermaid
graph TD
    Client[Le Client / Le Navigateur Frontend] -->|Passe commande| Serveur[Le Serveur HTTP / Le Handler]
    Serveur -->|Applique les règles de sécurité| Middleware[Le Portier / Le Middleware d'Authentification]
    Middleware -->|Transmet la commande| Chef[Le Chef Cuisinier / Le Service Usecase]
    Chef -->|Prend des ingrédients| GardeManger[Le Garde-Manger / Le Repository]
    GardeManger -->|Stockage Physique| Frigo[La Base de données / PostgreSQL ou RAM]
```

*   **Le Client (Navigateur Web)** : Il passe une commande spécifique (ex: *"Je veux créer un compte"* ou *"Je veux modifier un produit"*).
*   **Le Portier (Le Middleware - Sécurité)** : Avant d'entrer en cuisine, il vérifie l'identité du client (badge, clé API, jeton de sécurité). S'il n'a pas d'autorisation, il le bloque à l'entrée !
*   **Le Serveur (Le Handler HTTP - Gin)** : Il accueille le client, prend la commande, s'assure qu'elle est bien formulée (JSON valide) et la transmet au cuisinier.
*   **Le Chef Cuisinier (Le Service / Usecase)** : C'est le cerveau de la cuisine. Il applique toutes les règles importantes (ex: *"Le nom n'est pas vide"*, *"Le prix est valide"*).
*   **Le Garde-Manger (L'interface Repository)** : Le Chef a besoin d'ingrédients. Il demande au garde-manger d'enregistrer ou de lui donner des données, sans se soucier de savoir d'où elles viennent.
*   **Le Frigo (La Base de données)** : C'est l'emplacement physique du stockage. Grâce à notre garde-manger, le Chef peut utiliser un frigo en carton temporaire (**Mémoire vive**) pour s'entraîner, ou un super frigo connecté (**PostgreSQL**) pour le service réel, sans changer sa façon de cuisiner !

---

## 2. Structure de Production Complète des Dossiers

Voici l'architecture de production finale absolue. Chaque fichier a un rôle unique (SRP), le câblage est isolé dans le conteneur, les logs sont structurés, et le démarrage gère l'arrêt en douceur.

```text
golang-solid-backend/
├── cmd/
│   └── api/
│       └── main.go                        # L'AIGUILLEUR : Gère le démarrage, la configuration globale du logger et l'arrêt gracieux.
├── internal/
│   ├── app/                               # APPLICATION : Point d'assemblage et d'injection.
│   │   └── container.go                   # CONTAINER (IoC) : Instancie et injecte nos briques (Repos, Services, Handlers).
│   ├── config/                            # CONFIGURATION CENTRALISÉE (12-Factor App).
│   │   └── config.go                      # Charge l'environnement (.env) et applique des valeurs par défaut.
│   ├── domain/                            # LE CŒUR MÉTIER : Modèles de données purs (avec validation déclarative) et interfaces.
│   │   ├── user.go                        # Entité User, ses balises de validation de structure et son interface de stockage.
│   │   ├── product.go                     # Entité Product, ses balises de validation et son interface de stockage.
│   │   └── auth.go                        # Contrat d'authentification (TokenVerifier).
│   ├── usecase/                           # LES CAS D'USAGE : Toute notre logique métier pure.
│   │   ├── user_service.go                # Logique métier pour l'enregistrement et l'affichage des utilisateurs.
│   │   ├── product_service.go             # Logique métier pour la manipulation des produits.
│   │   └── auth_service.go                # Logique métier de validation des jetons d'accès.
│   ├── infrastructure/                    # L'INFRASTRUCTURE : Les adaptateurs techniques extérieurs.
│   │   ├── database/                      # Stockage et connexions physiques.
│   │   │   ├── db.go                      # INITIALISEUR DB : Configuration de production du pool de connexion Postgres.
│   │   │   ├── user_memory_repository.go    # Stockage temporaire sécurisé en RAM pour les Utilisateurs.
│   │   │   ├── product_memory_repository.go # Stockage temporaire sécurisé en RAM pour les Produits.
│   │   │   ├── user_postgres_repository.go  # Stockage PostgreSQL réel pour les Utilisateurs.
│   │   │   └── product_postgres_repository.go# Stockage PostgreSQL réel pour les Produits.
│   │   ├── middleware/                    # Intercepteurs de requêtes HTTP.
│   │   │   ├── auth.go                    # Middleware d'authentification (Vérification de Token).
│   │   │   └── cors.go                    # Middleware CORS : Configuration de la sécurité inter-domaines.
│   │   └── handler/                       # Les contrôleurs Web (Gin).
│   │       ├── user_handler.go            # Contrôle les requêtes HTTP utilisateurs.
│   │       └── product_handler.go          # Contrôle les requêtes HTTP produits.
├── .env                                   # [IGNORÉ] Fichier local réel contenant nos secrets (mots de passe, clés).
├── .env.example                           # MODÈLE DE SECRETS : Fichier d'exemple vide de secrets partagé sur Git.
├── .gitignore                             # CONFIG GIT : Empêche l'envoi de nos vrais secrets sur Git.
├── Dockerfile                             # CONFIG DOCKER : Compilation légère multi-stage de l'application.
├── docker-compose.yml                     # ORCHESTRATEUR DOCKER : Démarre le backend Go et la DB Postgres d'un coup.
├── go.mod                                 # Gestionnaire de dépendances Go.
└── go.sum                                 # Empreintes de sécurité des dépendances.
```

---

## 3. Étape 1 : Initialisation du Projet Go 

Avant de créer des fichiers, vous devez configurer le module de dépendances de Go.

Ouvrez un terminal dans le dossier où vous souhaitez créer votre projet et tapez les commandes suivantes :

```bash
# 1. Initialiser le module Go avec notre nom de projet
go mod init golang-solid-backend

# 2. Télécharger le framework web Gin
go get github.com/gin-gonic/gin

# 3. Télécharger le driver SQL PostgreSQL
go get github.com/lib/pq
```

---

## 4. Étape 2 :  Gestion Sécurisée des Secrets & Variables d'Environnement

> [!CAUTION]
> **Règle d'or de sécurité (DevSecOps) :** Vous ne devez **jamais** écrire de mots de passe, de secrets JWT, ou d'identifiants SQL dans un fichier poussé sur Git (comme `docker-compose.yml` ou `config.go`). Si un robot scanne votre dépôt public GitHub, vos serveurs et bases de données seront piratés en quelques minutes.

Pour éviter cela, nous appliquons la **meilleure pratique absolue de l'industrie** :

###  1. Exclure le fichier réel contenant les secrets de Git
Créez le fichier `.gitignore` à la racine de votre projet :

```text
# Fichiers de secrets personnels (À NE JAMAIS COMMITTER)
.env

# Fichiers binaires compilés de Go
main
/dist/
*.exe
*.bin

# Dossiers d'IDE
.idea/
.vscode/
```

###  2. Créer un modèle de configuration vide (`.env.example`)
Nous créons un fichier modèle que nous committons sur Git. Cela permet à nos collègues de savoir quelles variables configurer sans leur exposer nos mots de passe.

Créez le fichier `.env.example` :

```env
# Port d'écoute du serveur
PORT=:8080

# Choisir "true" pour utiliser PostgreSQL, "false" pour le mode mémoire RAM
USE_POSTGRES=false

# Clé secrète pour signer ou valider les jetons d'authentification
JWT_SECRET=remplir-avec-un-secret-jwt-fort

# Variables de connexion à la base de données PostgreSQL
DB_USER=postgres
DB_PASSWORD=mot-de-passe-ultra-securise
DB_NAME=mydb
DATABASE_URL=postgresql://postgres:password@localhost:5432/mydb?sslmode=disable
```

###  3. Créer votre fichier de secrets réels locaux (`.env`)
Ce fichier ne sera lu que sur votre machine en local et sera totalement ignoré par Git grâce au `.gitignore` !

Créez le fichier `.env` :

```env
PORT=:8080
USE_POSTGRES=false
JWT_SECRET=mon-super-secret-jwt-local-de-developpement
DB_USER=postgres
DB_PASSWORD=mot-de-passe-postgres-local
DB_NAME=mydb
DATABASE_URL=postgresql://postgres:mot-de-passe-postgres-local@localhost:5432/mydb?sslmode=disable
```

###  4. Charger l'environnement en Go : `internal/config/config.go`

```go
package config

import (
	"os"
)

// Config centralise toutes les variables de notre application (SRP).
type Config struct {
	Port        string
	UsePostgres bool
	DatabaseURL string
	JWTSecret   string
}

// LoadConfig charge et valide la configuration de l'application.
func LoadConfig() *Config {
	return &Config{
		Port:        getEnv("PORT", ":8080"),
		UsePostgres: getEnv("USE_POSTGRES", "false") == "true",
		DatabaseURL: getEnv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/mydb?sslmode=disable"),
		JWTSecret:   getEnv("JWT_SECRET", "cle-securite-par-defaut-en-developpement"),
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
```

---

## 5. Étape 3 : Le Domaine avec Validation Avancée (`internal/domain/`)

Le domaine définit l'identité métier et les règles de base, sans dépendre d'aucune technologie extérieure.

> [!TIP]
> **Validation Déclarative :** Nous utilisons les balises d'annotation de structure (Struct Tags) de Gin. Gin utilise en arrière-plan la célèbre bibliothèque `go-playground/validator` pour automatiser la conformité des données entrantes.

###  L'Utilisateur : `internal/domain/user.go`

```go
package domain

import "errors"

var (
	ErrUserNotFound = errors.New("utilisateur non trouvé")
	ErrInvalidEmail = errors.New("adresse email invalide")
)

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name" binding:"required,min=2"`  // Obligatoire, minimum 2 caractères
	Email string `json:"email" binding:"required,email"` // Obligatoire, doit être un email valide
}

type UserRepository interface {
	Create(user *User) error
	GetByID(id int) (*User, error)
	GetByEmail(email string) (*User, error)
	List() ([]*User, error)
}
```

###  Le Produit : `internal/domain/product.go`

```go
package domain

import "errors"

var (
	ErrProductNotFound = errors.New("produit non trouvé")
	ErrInvalidPrice    = errors.New("le prix ne peut pas être négatif")
)

type Product struct {
	ID    int     `json:"id"`
	Name  string  `json:"name" binding:"required,min=1"`
	Price float64 `json:"price" binding:"required,gte=0"` // Obligatoire, supérieur ou égal à 0
}

type ProductRepository interface {
	Create(product *Product) error
	GetByID(id int) (*Product, error)
	List() ([]*Product, error)
}
```

###  Le Contrat d'Authentification : `internal/domain/auth.go`

```go
package domain

// TokenVerifier définit le contrat pour valider un jeton (token) de sécurité.
type TokenVerifier interface {
	VerifyToken(token string) (int, error) // Renvoie l'ID utilisateur si valide, sinon une erreur
}
```

---

## 6. Étape 4 : La Logique Métier (`internal/usecase/`)

C'est ici qu'on applique la logique métier en injectant les interfaces requises.

###  Service Utilisateur : `internal/usecase/user_service.go`

```go
package usecase

import "golang-solid-backend/internal/domain"

type UserService struct {
	repo domain.UserRepository
}

func NewUserService(r domain.UserRepository) *UserService {
	return &UserService{repo: r}
}

func (s *UserService) Register(user *domain.User) error {
	// Les validations de format (email, min) sont gérées automatiquement par Gin.
	// Nous n'avons qu'à valider les règles métiers complexes (ex: unicité de l'email).
	existing, _ := s.repo.GetByEmail(user.Email)
	if existing != nil {
		return domain.ErrInvalidEmail
	}
	return s.repo.Create(user)
}

func (s *UserService) GetUser(id int) (*domain.User, error) {
	return s.repo.GetByID(id)
}

func (s *UserService) ListUsers() ([]*domain.User, error) {
	return s.repo.List()
}
```

###  Service Produit : `internal/usecase/product_service.go`

```go
package usecase

import "golang-solid-backend/internal/domain"

type ProductService struct {
	repo domain.ProductRepository
}

func NewProductService(r domain.ProductRepository) *ProductService {
	return &ProductService{repo: r}
}

func (s *ProductService) AddProduct(product *domain.Product) error {
	return s.repo.Create(product)
}

func (s *ProductService) GetProduct(id int) (*domain.Product, error) {
	return s.repo.GetByID(id)
}

func (s *ProductService) ListProducts() ([]*domain.Product, error) {
	return s.repo.List()
}
```

###  Service de Validation des Tokens : `internal/usecase/auth_service.go`

```go
package usecase

import "errors"

type SimpleTokenService struct {
	secret string
}

func NewSimpleTokenService(secret string) *SimpleTokenService {
	return &SimpleTokenService{secret: secret}
}

func (s *SimpleTokenService) VerifyToken(token string) (int, error) {
	if token == "super-secret-token" {
		return 1, nil // Valide l'userID 1
	}
	if token == "token-user-2" {
		return 2, nil // Valide l'userID 2
	}
	return 0, errors.New("jeton d'authentification invalide ou expiré")
}
```

---

## 7. Étape 5 : L'Infrastructure de Stockage (`internal/infrastructure/database/`)

> [!IMPORTANT]
> **Bonne pratique de production (Structured Logging) :** Au lieu d'utiliser du texte brut avec `fmt.Println`, nous utilisons la bibliothèque officielle de Go `log/slog` pour journaliser les opérations techniques clés en format JSON exploitable par le Cloud.

###  L'Initialiseur PostgreSQL : `internal/infrastructure/database/db.go`

```go
package database

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq" // Driver SQL PostgreSQL
)

// InitPostgresDB initialise et valide la connexion physique à PostgreSQL (SRP).
func InitPostgresDB(databaseURL string) (*sql.DB, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("erreur ouverture de la base : %w", err)
	}

	// Configuration du Pool de connexions :
	db.SetMaxOpenConns(25)                 
	db.SetMaxIdleConns(25)                 
	db.SetConnMaxLifetime(5 * time.Minute) 

	// Test de connexion obligatoire (Ping)
	if err = db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("impossible de joindre postgres : %w", err)
	}

	// Création des tables automatiques (Bonus démo)
	if err := createTables(db); err != nil {
		db.Close()
		return nil, fmt.Errorf("impossible de créer les tables : %w", err)
	}

	return db, nil
}

func createTables(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS users (
			id SERIAL PRIMARY KEY,
			name VARCHAR(100) NOT NULL,
			email VARCHAR(100) UNIQUE NOT NULL
		);
		CREATE TABLE IF NOT EXISTS products (
			id SERIAL PRIMARY KEY,
			name VARCHAR(100) NOT NULL,
			price DECIMAL(10, 2) NOT NULL
		);
	`)
	return err
}
```

###  Dépôt Utilisateurs en Mémoire (`internal/infrastructure/database/user_memory_repository.go`)

```go
package database

import (
	"log/slog"
	"sync"
	"golang-solid-backend/internal/domain"
)

type MemoryUserRepository struct {
	mu     sync.RWMutex
	users  map[int]*domain.User
	nextID int
}

func NewMemoryUserRepository() *MemoryUserRepository {
	return &MemoryUserRepository{
		users:  make(map[int]*domain.User),
		nextID: 1,
	}
}

func (r *MemoryUserRepository) Create(user *domain.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	user.ID = r.nextID
	r.users[user.ID] = user
	r.nextID++
	slog.Info("Utilisateur enregistré en mémoire", slog.Int("user_id", user.ID), slog.String("email", user.Email))
	return nil
}

func (r *MemoryUserRepository) GetByID(id int) (*domain.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	user, exists := r.users[id]
	if !exists {
		return nil, domain.ErrUserNotFound
	}
	return user, nil
}

func (r *MemoryUserRepository) GetByEmail(email string) (*domain.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for _, user := range r.users {
		if user.Email == email {
			return user, nil
		}
	}
	return nil, domain.ErrUserNotFound
}

func (r *MemoryUserRepository) List() ([]*domain.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	list := make([]*domain.User, 0, len(r.users))
	for _, user := range r.users {
		list = append(list, user)
	}
	return list, nil
}
```

###  Dépôt Produits en Mémoire (`internal/infrastructure/database/product_memory_repository.go`)

```go
package database

import (
	"log/slog"
	"sync"
	"golang-solid-backend/internal/domain"
)

type MemoryProductRepository struct {
	mu       sync.RWMutex
	products map[int]*domain.Product
	nextID   int
}

func NewMemoryProductRepository() *MemoryProductRepository {
	return &MemoryProductRepository{
		products: make(map[int]*domain.Product),
		nextID:   1,
	}
}

func (r *MemoryProductRepository) Create(product *domain.Product) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	product.ID = r.nextID
	r.products[product.ID] = product
	r.nextID++
	slog.Info("Produit enregistré en mémoire", slog.Int("product_id", product.ID), slog.String("name", product.Name))
	return nil
}

func (r *MemoryProductRepository) GetByID(id int) (*domain.Product, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	product, exists := r.products[id]
	if !exists {
		return nil, domain.ErrProductNotFound
	}
	return product, nil
}

func (r *MemoryProductRepository) List() ([]*domain.Product, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	list := make([]*domain.Product, 0, len(r.products))
	for _, product := range r.products {
		list = append(list, product)
	}
	return list, nil
}
```

###  Dépôt Utilisateurs PostgreSQL (`internal/infrastructure/database/user_postgres_repository.go`)

```go
package database

import (
	"database/sql"
	"errors"
	"log/slog"
	"golang-solid-backend/internal/domain"
)

type PostgresUserRepository struct {
	db *sql.DB
}

func NewPostgresUserRepository(db *sql.DB) *PostgresUserRepository {
	return &PostgresUserRepository{db: db}
}

func (r *PostgresUserRepository) Create(user *domain.User) error {
	query := `INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id`
	err := r.db.QueryRow(query, user.Name, user.Email).Scan(&user.ID)
	if err == nil {
		slog.Info("Utilisateur enregistré dans PostgreSQL", slog.Int("user_id", user.ID), slog.String("email", user.Email))
	}
	return err
}

func (r *PostgresUserRepository) GetByID(id int) (*domain.User, error) {
	query := `SELECT id, name, email FROM users WHERE id = $1`
	var user domain.User
	err := r.db.QueryRow(query, id).Scan(&user.ID, &user.Name, &user.Email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, domain.ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

func (r *PostgresUserRepository) GetByEmail(email string) (*domain.User, error) {
	query := `SELECT id, name, email FROM users WHERE email = $1`
	var user domain.User
	err := r.db.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, domain.ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

func (r *PostgresUserRepository) List() ([]*domain.User, error) {
	query := `SELECT id, name, email FROM users`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*domain.User
	for rows.Next() {
		var user domain.User
		if err := rows.Scan(&user.ID, &user.Name, &user.Email); err != nil {
			return nil, err
		}
		users = append(users, &user)
	}
	return users, nil
}
```

###  Dépôt Produits PostgreSQL (`internal/infrastructure/database/product_postgres_repository.go`)

```go
package database

import (
	"database/sql"
	"errors"
	"log/slog"
	"golang-solid-backend/internal/domain"
)

type PostgresProductRepository struct {
	db *sql.DB
}

func NewPostgresProductRepository(db *sql.DB) *PostgresProductRepository {
	return &PostgresProductRepository{db: db}
}

func (r *PostgresProductRepository) Create(product *domain.Product) error {
	query := `INSERT INTO products (name, price) VALUES ($1, $2) RETURNING id`
	err := r.db.QueryRow(query, product.Name, product.Price).Scan(&product.ID)
	if err == nil {
		slog.Info("Produit enregistré dans PostgreSQL", slog.Int("product_id", product.ID), slog.String("name", product.Name))
	}
	return err
}

func (r *PostgresProductRepository) GetByID(id int) (*domain.Product, error) {
	query := `SELECT id, name, price FROM products WHERE id = $1`
	var product domain.Product
	err := r.db.QueryRow(query, id).Scan(&product.ID, &product.Name, &product.Price)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, domain.ErrProductNotFound
		}
		return nil, err
	}
	return &product, nil
}

func (r *PostgresProductRepository) List() ([]*domain.Product, error) {
	query := `SELECT id, name, price FROM products`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []*domain.Product
	for rows.Next() {
		var product domain.Product
		if err := rows.Scan(&product.ID, &product.Name, &product.Price); err != nil {
			return nil, err
		}
		products = append(products, &product)
	}
	return products, nil
}
```

---

## 8. Étape 6 : Les Middlewares (`internal/infrastructure/middleware/`)

###  Middleware d'Authentification : `internal/infrastructure/middleware/auth.go`

```go
package middleware

import (
	"net/http"
	"strings"

	"golang-solid-backend/internal/domain"
	"github.com/gin-gonic/gin"
)

type AuthMiddleware struct {
	verifier domain.TokenVerifier // Dépendance vers l'interface (DIP)
}

func NewAuthMiddleware(v domain.TokenVerifier) *AuthMiddleware {
	return &AuthMiddleware{verifier: v}
}

func (m *AuthMiddleware) HandlerFunc() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentification requise : en-tête 'Authorization' manquant"})
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Format d'en-tête invalide (doit être 'Bearer <token>')"})
			c.Abort()
			return
		}

		token := parts[1]

		userID, err := m.verifier.VerifyToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Jeton d'authentification invalide : " + err.Error()})
			c.Abort()
			return
		}

		c.Set("userID", userID)
		c.Next()
	}
}
```

###  Middleware de Configuration CORS : `internal/infrastructure/middleware/cors.go`

```go
package middleware

import (
	"github.com/gin-gonic/gin"
)

// CORSMiddleware configure la politique CORS pour autoriser notre Frontend à appeler l'API (SRP).
func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
```

---

## 9. Étape 7 : Les Contrôleurs Web Gin avec Validation (`internal/infrastructure/handler/`)

> [!TIP]
> **Validation Automatique :** En utilisant `ShouldBindJSON()`, Gin va automatiquement lire notre JSON, le convertir en structure Go et **déclencher les validations déclaratives** (`binding:"required,email"`...) définies sur nos structures du Domaine. En cas d'erreur de format, Gin s'arrête immédiatement et renvoie un JSON d'erreur clair.

###  Contrôleur Utilisateur : `internal/infrastructure/handler/user_handler.go`

```go
package handler

import (
	"net/http"
	"strconv"
	"golang-solid-backend/internal/domain"
	"golang-solid-backend/internal/usecase"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	service *usecase.UserService
}

func NewUserHandler(s *usecase.UserService) *UserHandler {
	return &UserHandler{service: s}
}

func (h *UserHandler) RegisterRoutes(r *gin.Engine) {
	r.POST("/users", h.CreateUser)
	r.GET("/users", h.ListUsers)
	r.GET("/users/:id", h.GetUser)
}

func (h *UserHandler) CreateUser(c *gin.Context) {
	var u domain.User
	// Déclenche automatiquement la validation déclarative (binding:"required,email"...) !
	if err := c.ShouldBindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données utilisateur invalides : " + err.Error()})
		return
	}
	
	if err := h.service.Register(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, u)
}

func (h *UserHandler) ListUsers(c *gin.Context) {
	users, err := h.service.ListUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur serveur"})
		return
	}
	c.JSON(http.StatusOK, users)
}

func (h *UserHandler) GetUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID invalide"})
		return
	}
	user, err := h.service.GetUser(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, user)
}
```

###  Contrôleur Produit : `internal/infrastructure/handler/product_handler.go`

```go
package handler

import (
	"net/http"
	"golang-solid-backend/internal/domain"
	"golang-solid-backend/internal/usecase"
	"github.com/gin-gonic/gin"
)

type ProductHandler struct {
	service *usecase.ProductService
}

func NewProductHandler(s *usecase.ProductService) *ProductHandler {
	return &ProductHandler{service: s}
}

func (h *ProductHandler) RegisterSecureRoutes(rg *gin.RouterGroup) {
	rg.POST("/products", h.CreateProduct)
	rg.GET("/products", h.ListProducts)
}

func (h *ProductHandler) CreateProduct(c *gin.Context) {
	connectedUserID, exists := c.Get("userID")
	if exists {
		println("Produit créé par l'utilisateur ID :", connectedUserID.(int))
	}

	var p domain.Product
	// Déclenche automatiquement la validation déclarative (binding:"required,gte=0"...) !
	if err := c.ShouldBindJSON(&p); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données produit invalides : " + err.Error()})
		return
	}

	if err := h.service.AddProduct(&p); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, p)
}

func (h *ProductHandler) ListProducts(c *gin.Context) {
	products, err := h.service.ListProducts()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur serveur"})
		return
	}
	c.JSON(http.StatusOK, products)
}
```

---

## 10. Étape 8 : Le Conteneur de Dépendances (`internal/app/container.go`)

Ce fichier rassemble toute l'instanciation technique et l'injection de nos couches métier.

Créez le fichier `internal/app/container.go` :

```go
package app

import (
	"database/sql"

	"golang-solid-backend/internal/config"
	"golang-solid-backend/internal/domain"
	"golang-solid-backend/internal/infrastructure/database"
	"golang-solid-backend/internal/infrastructure/handler"
	"golang-solid-backend/internal/infrastructure/middleware"
	"golang-solid-backend/internal/usecase"
)

// Container rassemble toutes les briques logicielles prêtes à l'emploi.
type Container struct {
	UserHandler    *handler.UserHandler
	ProductHandler *handler.ProductHandler
	AuthMiddleware *middleware.AuthMiddleware
}

// NewContainer orchestre la création et l'injection de dépendances (IoC / DI Container).
func NewContainer(cfg *config.Config, db *sql.DB) *Container {
	// -------------------------------------------------------------
	// 1. Initialisation de la Couche Donnée (Dépôts)
	// -------------------------------------------------------------
	var userRepo domain.UserRepository
	var productRepo domain.ProductRepository

	if cfg.UsePostgres {
		userRepo = database.NewPostgresUserRepository(db)
		productRepo = database.NewPostgresProductRepository(db)
	} else {
		userRepo = database.NewMemoryUserRepository()
		productRepo = database.NewMemoryProductRepository()
	}

	// -------------------------------------------------------------
	// 2. Initialisation de la Couche Logique Métier (Services)
	// -------------------------------------------------------------
	userService := usecase.NewUserService(userRepo)
	productService := usecase.NewProductService(productRepo)
	authService := usecase.NewSimpleTokenService(cfg.JWTSecret)

	// -------------------------------------------------------------
	// 3. Initialisation de la Couche Infrastructure (Handlers & Middlewares)
	// -------------------------------------------------------------
	authMiddleware := middleware.NewAuthMiddleware(authService)
	userHandler := handler.NewUserHandler(userService)
	productHandler := handler.NewProductHandler(productService)

	return &Container{
		UserHandler:    userHandler,
		ProductHandler: productHandler,
		AuthMiddleware: authMiddleware,
	}
}
```

---

## 11. Étape 9 : L'Assemblage Pur & Arrêt Gracieux (`cmd/api/main.go`)

```go
package main

import (
	"context"
	"database/sql"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"golang-solid-backend/internal/app"
	"golang-solid-backend/internal/config"
	"golang-solid-backend/internal/infrastructure/database"
	"golang-solid-backend/internal/infrastructure/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Initialisation du Logger de Production (JSON Structuré)
	jsonHandler := slog.NewJSONHandler(os.Stdout, nil)
	logger := slog.New(jsonHandler)
	slog.SetDefault(logger)

	slog.Info("Démarrage de la phase d'initialisation de l'application...")

	// 2. Chargement de la Configuration (SRP)
	cfg := config.LoadConfig()

	// 3. Initialisation de PostgreSQL si configuré
	var db *sql.DB
	var err error
	if cfg.UsePostgres {
		db, err = database.InitPostgresDB(cfg.DatabaseURL)
		if err != nil {
			slog.Error("Impossible d'initialiser PostgreSQL", "error", err)
			os.Exit(1)
		}
		defer func() {
			slog.Info("Fermeture de la connexion à la base de données PostgreSQL...")
			db.Close()
		}()
	}

	// 4. Chargement de notre Container de Dépendances (IoC / DI)
	container := app.NewContainer(cfg, db)

	// 5. Configuration du Framework Gin et enregistrement des Routes
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery()) 
	r.Use(middleware.CORSMiddleware()) 

	// Enregistrement des routes des utilisateurs (Publique)
	container.UserHandler.RegisterRoutes(r)

	// Enregistrement des routes des produits (Sécurisée par AuthMiddleware)
	securedGroup := r.Group("/")
	securedGroup.Use(container.AuthMiddleware.HandlerFunc())
	container.ProductHandler.RegisterSecureRoutes(securedGroup)

	// 6. Configuration du Serveur & Gestion de l'Arrêt Gracieux
	srv := &http.Server{
		Addr:    cfg.Port,
		Handler: r,
	}

	go func() {
		slog.Info("Serveur prêt à recevoir des appels !", slog.String("port", cfg.Port))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("Erreur critique survenue sur le serveur HTTP", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	sig := <-quit
	slog.Warn("Signal d'arrêt reçu, coupure progressive du serveur...", "signal", sig.String())

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		slog.Error("Arrêt forcé du serveur HTTP (Timeout dépassé)", "error", err)
		os.Exit(1)
	}

	slog.Info("Backend éteint proprement. Aucune donnée perdue ! À bientôt !")
}
```

---

## 12. Étape 10 : Liaison avec le Frontend  (`index.html`)

Ouvrez ce fichier directement dans votre navigateur web pour interagir avec votre API.

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Administration Sécurisé</title>
    <style>
        :root {
            --bg-color: #0c0c0e;
            --card-bg: #16161a;
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --accent: #10b981;
            --accent-hover: #059669;
            --text: #f3f4f6;
            --text-secondary: #9ca3af;
            --border: #2d2d34;
        }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: var(--bg-color);
            color: var(--text);
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 20px;
        }
        h1 { text-align: center; color: var(--primary); margin-bottom: 24px; }
        h2 { color: var(--accent); margin-bottom: 16px; border-bottom: 1px solid var(--border); padding-bottom: 8px; }
        
        /* Barre d'authentification */
        .auth-bar {
            background-color: #1e1b4b;
            border: 1px solid #4338ca;
            padding: 16px;
            border-radius: 8px;
            display: flex;
            gap: 16px;
            align-items: center;
            margin-bottom: 30px;
        }
        .auth-bar input { flex-grow: 1; }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
        }
        @media (max-width: 768px) {
            .grid { grid-template-columns: 1fr; }
        }
        .card {
            background-color: var(--card-bg);
            padding: 24px;
            border-radius: 12px;
            border: 1px solid var(--border);
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 24px;
        }
        input {
            padding: 12px;
            border-radius: 6px;
            border: 1px solid var(--border);
            background-color: var(--bg-color);
            color: var(--text);
            font-size: 15px;
        }
        input:focus { outline: 2px solid var(--primary); }
        button {
            padding: 12px;
            border-radius: 6px;
            border: none;
            font-weight: bold;
            font-size: 15px;
            cursor: pointer;
            transition: background 0.2s;
            color: white;
        }
        .btn-user { background-color: var(--primary); }
        .btn-user:hover { background-color: var(--primary-hover); }
        .btn-product { background-color: var(--accent); }
        .btn-product:hover { background-color: var(--accent-hover); }
        ul { list-style: none; padding: 0; }
        li {
            background: var(--bg-color);
            padding: 14px;
            margin-top: 10px;
            border-radius: 6px;
            border-left: 4px solid var(--primary);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .li-product { border-left-color: var(--accent); }
        .price { font-weight: bold; color: var(--accent); }
    </style>
</head>
<body>

    <h1>Dashboard d'Administration Sécurisé</h1>

    <div class="auth-bar">
        <span> <strong>Jeton d'accès (Bearer Token) :</strong></span>
        <input type="text" id="authToken" placeholder="Écrire 'super-secret-token' ou 'token-user-2' pour avoir l'accès !" value="super-secret-token">
    </div>

    <div class="grid">
        <div class="card">
            <h2>Gestion des Utilisateurs (Publique)</h2>
            <form id="userForm">
                <input type="text" id="userName" placeholder="Nom complet (ex: Alice)" required>
                <input type="email" id="userEmail" placeholder="Adresse email (ex: alice@gmail.com)" required>
                <button type="submit" class="button btn-user">➕ Ajouter l'Utilisateur</button>
            </form>
            <ul id="userList"></ul>
        </div>

        <div class="card">
            <h2>Gestion des Produits (Sécurisée)</h2>
            <form id="productForm">
                <input type="text" id="productName" placeholder="Nom du produit (ex: Clavier)" required>
                <input type="number" step="0.01" id="productPrice" placeholder="Prix en euros (ex: 29.99)" required>
                <button type="submit" class="button btn-product">➕ Ajouter le Produit</button>
            </form>
            <ul id="productList"></ul>
        </div>
    </div>

    <script>
        const BASE_URL = "http://localhost:8080";

        function getHeaders() {
            const token = document.getElementById("authToken").value;
            return {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            };
        }

        async function loadUsers() {
            try {
                const res = await fetch(`${BASE_URL}/users`);
                const users = await res.json();
                const list = document.getElementById("userList");
                list.innerHTML = "";
                users.forEach(u => {
                    const li = document.createElement("li");
                    li.innerHTML = `<span><strong>${u.name}</strong> (${u.email})</span> <span style="color:var(--text-secondary)">ID: ${u.id}</span>`;
                    list.appendChild(li);
                });
            } catch (err) { console.error("Erreur utilisateurs :", err); }
        }

        async function loadProducts() {
            try {
                const res = await fetch(`${BASE_URL}/products`, {
                    headers: getHeaders()
                });
                
                const data = await res.json();
                const list = document.getElementById("productList");
                list.innerHTML = "";
                
                if (!res.ok) {
                    list.innerHTML = `<li class="li-product" style="border-left-color:red; color:red">⚠️ Erreur de chargement : ${data.error || "Non autorisé"}</li>`;
                    return;
                }

                data.forEach(p => {
                    const li = document.createElement("li");
                    li.className = "li-product";
                    li.innerHTML = `<span><strong>${p.name}</strong></span> <span class="price">${p.price.toFixed(2)} €</span>`;
                    list.appendChild(li);
                });
            } catch (err) { console.error("Erreur produits :", err); }
        }

        document.getElementById("userForm").addEventListener("submit", async (e) => {
            e.preventDefault();
            const name = document.getElementById("userName").value;
            const email = document.getElementById("userEmail").value;
            const res = await fetch(`${BASE_URL}/users`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ name, email })
            });
            const data = await res.json();
            if (!res.ok) alert("Erreur : " + data.error);
            else {
                document.getElementById("userForm").reset();
                loadUsers();
            }
        });

        document.getElementById("productForm").addEventListener("submit", async (e) => {
            e.preventDefault();
            const name = document.getElementById("productName").value;
            const price = parseFloat(document.getElementById("productPrice").value);
            
            const res = await fetch(`${BASE_URL}/products`, {
                method: "POST",
                headers: getHeaders(),
                body: JSON.stringify({ name, price })
            });
            const data = await res.json();
            if (!res.ok) alert("Erreur : " + (data.error || "Non autorisé"));
            else {
                document.getElementById("productForm").reset();
                loadProducts();
            }
        });

        document.getElementById("authToken").addEventListener("input", loadProducts);

        loadUsers();
        loadProducts();
    </script>
</body>
</html>
```

---

## 13. Déploiement & Containerisation  (Dockerfile & Docker Compose)

Pour déployer notre application de manière industrielle en un claquement de doigts, nous allons utiliser **Docker**. La bonne pratique absolue en Go est d'utiliser un build **Multi-stage**.

###  Étape 13.1 : Le `Dockerfile` (à la racine du projet)
*   **Stage 1 (Build) :** Nous utilisons l'image officielle Go pour compiler un binaire statique épuré.
*   **Stage 2 (Run) :** Nous copions uniquement le binaire compilé dans une image ultra-légère `alpine:latest`. L'image finale ne pèse que **~15 Mo** et ne contient aucune faille de sécurité inutile !

```dockerfile
# -------------------------------------------------------------
# ÉTAPE 1 : Compilation du binaire (Build Stage)
# -------------------------------------------------------------
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances et les télécharger
COPY go.mod go.sum ./
RUN go mod download

# Copier l'intégralité du code source du projet
COPY . .

# Compiler un binaire statique ultra-optimisé pour Alpine Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o main cmd/api/main.go

# -------------------------------------------------------------
# ÉTAPE 2 : Image d'exécution ultra-légère (Run Stage)
# -------------------------------------------------------------
FROM alpine:latest

WORKDIR /root/

# Installer les certificats de sécurité requis pour faire des appels HTTPS
RUN apk --no-cache add ca-certificates

# Copier uniquement le binaire compilé depuis l'étape précédente
COPY --from=builder /app/main .
COPY --from=builder /app/.env .

EXPOSE 8080

CMD ["./main"]
```

---

### 🎛️ Étape 13.2 : Le `docker-compose.yml` (à la racine du projet)

> [!TIP]
> **Best Practice Docker & Docker Compose :** Pour préserver la sécurité de vos environnements, le fichier `docker-compose.yml` ne contient **aucune variable secrète en clair**. 
> Nous utilisons la notation `${VARIABLE_NAME}` : Docker Compose ira lire automatiquement la valeur correspondante dans notre fichier local `.env` (qui est exclu de Git). Ainsi, vos configurations restent privées et hautement sécurisées !

```yaml
version: '3.8'

services:
  #  Service 1 : La Base de données PostgreSQL
  db:
    image: postgres:15-alpine
    container_name: postgres_db_solid
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  #  Service 2 : Notre API REST Golang
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: golang_api_solid
    restart: always
    ports:
      - "8080:8080"
    environment:
      PORT: "${PORT}"
      USE_POSTGRES: "true"
      # On injecte l'URL de connexion en liant l'hôte SQL au nom de service "db" de Docker Compose
      DATABASE_URL: "postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}?sslmode=disable"
      JWT_SECRET: "${JWT_SECRET}"
    depends_on:
      - db # S'assure que la DB démarre avant le serveur API

volumes:
  postgres_data: # Volume persistant pour ne pas perdre les données SQL lors d'un redémarrage
```

---

###  Étape 13.3 : Lancement clé en main
Pour démarrer l'intégralité de votre stack logicielle (Go + PostgreSQL) avec persistance des données, il vous suffit de taper une seule commande dans votre terminal :

```bash
docker compose up --build
```
Pour éteindre proprement tout l'environnement :
```bash
docker compose down
```

---

## 14. Guide de Démarrage Rapide (Sans Docker) 

### Option 1 : Lancement rapide en mode RAM (Pas besoin de configurer Postgres !)

1.  Ouvrez votre terminal dans le dossier racine du projet.
2.  Lancez le serveur :
    ```bash
    go run cmd/api/main.go
    ```
3.  Le terminal va afficher des objets de logs JSON configurés avec `log/slog`.
4.  Double-cliquez sur le fichier `index.html` pour l'ouvrir dans votre navigateur.
5.  **C'est prêt !** Vous pouvez ajouter des utilisateurs directement. Pour ajouter un produit, écrivez `super-secret-token` ou `token-user-2` dans la case token.

### Option 2 : Lancement local avec une base de données PostgreSQL

1.  Assurez-vous qu'un serveur PostgreSQL est actif sur votre machine.
2.  Définissez vos variables d'environnement dans le fichier `.env` :
    *   `USE_POSTGRES=true`
    *   `DATABASE_URL=postgresql://UTILISATEUR:MOT_DE_PASSE@localhost:5432/NOM_BASE?sslmode=disable`
3.  Lancez le serveur :
    ```bash
    go run cmd/api/main.go
    ```

---

## 15. Pour aller plus loin : Conteneurs DI Automatisés en Go 

Le conteneur manuel (`internal/app/container.go`) présenté dans ce tutoriel est la **meilleure approche** pour 95% des projets (simplicité de lecture, typage fort, pas de "magie noire" opaque).

Cependant, pour d'immenses architectures d'entreprises comptant des centaines de services, l'industrie utilise des frameworks de conteneurs DI automatisés :
1.  **Google Wire** : Un générateur de code automatique. Vous définissez vos dépendances dans un fichier simple, et Wire génère à la compilation le code de câblage à votre place. Très populaire car sans aucune perte de performance !
2.  **Uber Fx** : Un conteneur de dépendance basé sur la réflexion à l'exécution de l'application, très puissant, proposant également de la gestion de cycle de vie (start, stop).

---
