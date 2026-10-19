-- =====================================================
-- FormaTIC - Modelo de datos (MySQL 8)
-- =====================================================
DROP DATABASE IF EXISTS formatic;
CREATE DATABASE formatic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE formatic;

-- ---------- ROL ----------
CREATE TABLE rol (
    id_rol      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ---------- USUARIO ----------
CREATE TABLE usuario (
    id_usuario            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_completo       VARCHAR(120) NOT NULL,
    numero_identificacion VARCHAR(20)  NOT NULL UNIQUE,
    correo                VARCHAR(120) NOT NULL UNIQUE,
    contrasena_hash       VARCHAR(255) NOT NULL,
    estado                ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    fecha_registro        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_rol                INT UNSIGNED NOT NULL,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
) ENGINE=InnoDB;

-- ---------- TOKEN_RECUPERACION (RF03) ----------
CREATE TABLE token_recuperacion (
    id_token         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    token            VARCHAR(255) NOT NULL UNIQUE,
    fecha_expiracion DATETIME NOT NULL,
    usado            BOOLEAN NOT NULL DEFAULT FALSE,
    id_usuario       INT UNSIGNED NOT NULL,
    CONSTRAINT fk_token_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- PROYECTO (RF05, RF13) ----------
CREATE TABLE proyecto (
    id_proyecto   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL,
    descripcion   TEXT,
    objetivos     TEXT,
    fecha_inicio  DATE NOT NULL,
    fecha_fin     DATE NOT NULL,
    estado        ENUM('activo','en_pausa','finalizado') NOT NULL DEFAULT 'activo',
    id_instructor INT UNSIGNED NOT NULL,
    CONSTRAINT fk_proyecto_instructor FOREIGN KEY (id_instructor) REFERENCES usuario(id_usuario),
    CONSTRAINT chk_proyecto_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- ---------- PROYECTO_APRENDIZ (RF06, N:M) ----------
CREATE TABLE proyecto_aprendiz (
    id_proyecto      INT UNSIGNED NOT NULL,
    id_aprendiz      INT UNSIGNED NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_proyecto, id_aprendiz),
    CONSTRAINT fk_pa_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
        ON DELETE CASCADE,
    CONSTRAINT fk_pa_aprendiz FOREIGN KEY (id_aprendiz) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- ---------- ACTIVIDAD (RF07) ----------
CREATE TABLE actividad (
    id_actividad         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    titulo               VARCHAR(150) NOT NULL,
    descripcion          TEXT,
    fecha_limite         DATETIME NOT NULL,
    criterios_evaluacion TEXT,
    id_proyecto          INT UNSIGNED NOT NULL,
    CONSTRAINT fk_actividad_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- ENTREGA (RF16, RF08) ----------
CREATE TABLE entrega (
    id_entrega   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    estado       ENUM('pendiente','entregada','en_revision','requiere_ajustes','calificada')
                 NOT NULL DEFAULT 'pendiente',
    id_actividad INT UNSIGNED NOT NULL,
    id_aprendiz  INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_entrega_actividad_aprendiz (id_actividad, id_aprendiz),
    CONSTRAINT fk_entrega_actividad FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad)
        ON DELETE CASCADE,
    CONSTRAINT fk_entrega_aprendiz FOREIGN KEY (id_aprendiz) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- ---------- VERSION_ENTREGA (RF18, RF20) ----------
CREATE TABLE version_entrega (
    id_version          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero_version      INT UNSIGNED NOT NULL DEFAULT 1,
    comentario_aprendiz TEXT,
    fecha_envio         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_entrega          INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_version_entrega (id_entrega, numero_version),
    CONSTRAINT fk_version_entrega FOREIGN KEY (id_entrega) REFERENCES entrega(id_entrega)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- EVIDENCIA (RF16, RNF07) ----------
CREATE TABLE evidencia (
    id_evidencia    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tipo            ENUM('archivo','enlace') NOT NULL,
    ruta_o_url      VARCHAR(500) NOT NULL,
    nombre_original VARCHAR(255),
    id_version      INT UNSIGNED NOT NULL,
    CONSTRAINT fk_evidencia_version FOREIGN KEY (id_version) REFERENCES version_entrega(id_version)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- RETROALIMENTACION (RF10, RF11, RF17) ----------
CREATE TABLE retroalimentacion (
    id_retro               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    comentario             TEXT NOT NULL,
    solicita_nueva_version BOOLEAN NOT NULL DEFAULT FALSE,
    fecha                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_version             INT UNSIGNED NOT NULL,
    id_instructor          INT UNSIGNED NOT NULL,
    CONSTRAINT fk_retro_version FOREIGN KEY (id_version) REFERENCES version_entrega(id_version)
        ON DELETE CASCADE,
    CONSTRAINT fk_retro_instructor FOREIGN KEY (id_instructor) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- ---------- CALIFICACION (RF09, RF19) ----------
-- Admite nota numerica, juicio evaluativo o ambos (por definir con el cliente)
CREATE TABLE calificacion (
    id_calificacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    valor_numerico  DECIMAL(4,2) NULL,
    juicio          ENUM('aprobado','no_aprobado') NULL,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_version      INT UNSIGNED NOT NULL,
    id_instructor   INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_calificacion_version (id_version),
    CONSTRAINT fk_calif_version FOREIGN KEY (id_version) REFERENCES version_entrega(id_version)
        ON DELETE CASCADE,
    CONSTRAINT fk_calif_instructor FOREIGN KEY (id_instructor) REFERENCES usuario(id_usuario),
    CONSTRAINT chk_calif_valor CHECK (valor_numerico IS NULL OR valor_numerico BETWEEN 0 AND 5)
) ENGINE=InnoDB;

-- ---------- NOTIFICACION (RF21) ----------
CREATE TABLE notificacion (
    id_notificacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tipo            ENUM('nueva_actividad','calificacion','retroalimentacion','asignacion','otro')
                    NOT NULL DEFAULT 'otro',
    mensaje         VARCHAR(300) NOT NULL,
    leida           BOOLEAN NOT NULL DEFAULT FALSE,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario      INT UNSIGNED NOT NULL,
    CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- MENSAJE (RF22, Plus) ----------
CREATE TABLE mensaje (
    id_mensaje      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contenido       TEXT NOT NULL,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leido           BOOLEAN NOT NULL DEFAULT FALSE,
    id_remitente    INT UNSIGNED NOT NULL,
    id_destinatario INT UNSIGNED NOT NULL,
    CONSTRAINT fk_msg_remitente FOREIGN KEY (id_remitente) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_msg_destinatario FOREIGN KEY (id_destinatario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- ---------- Datos iniciales ----------
INSERT INTO rol (nombre) VALUES ('Administrador'), ('Instructor'), ('Aprendiz');
