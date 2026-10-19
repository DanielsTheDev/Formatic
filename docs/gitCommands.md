# Comandos de Git — FormaTIC

Chuleta personal. Los comandos marcados con ⚠️ pueden hacerte perder trabajo: úsalos con cuidado.

---

## 1. Configuración inicial (solo la primera vez en tu computador)

```bash
git config --global user.name "Tu Nombre"        # Tu nombre como autor de los commits
git config --global user.email "tu@correo.com"   # Usa el mismo correo verificado en GitHub
git config --global init.defaultBranch main      # Las ramas nuevas se llamarán "main"
git config --global core.autocrlf true           # Windows: evita el aviso de LF/CRLF
git config --list                                # Muestra toda tu configuración
```

---

## 2. Empezar un proyecto

### Opción A: crear un repositorio nuevo desde tu carpeta

```bash
git init                 # Convierte la carpeta en repositorio (crea la carpeta oculta .git)
git branch -M main       # Renombra la rama principal a "main", el estándar de GitHub
```

### Opción B: descargar uno que ya existe en GitHub

```bash
git clone https://github.com/USUARIO/REPO.git   # Copia el repositorio completo a tu computador
```

### Conectar tu repo local con GitHub (primero crea un repo vacío en github.com, sin README)

```bash
git remote add origin https://github.com/USUARIO/REPO.git   # Define la dirección del repo remoto
git push -u origin main  # Sube la rama main; el -u recuerda la conexión para la próxima vez
```

---

## 3. El ciclo diario: ver, preparar, guardar, subir

```bash
git pull                          # 1. Trae lo que otros subieron (haz esto ANTES de trabajar)
git status                        # 2. Muestra qué cambió y qué está preparado
git add archivo.py                # 3. Prepara UN archivo (pasa a "staged")
git add carpeta/                  #    Prepara una carpeta completa
git add .                         #    Prepara TODO (revisa antes con git status)
git commit -m "feat: agrega login"   # 4. Guarda una "foto" de lo preparado, con un mensaje
git push                          # 5. Sube tus commits a GitHub
```

Los tres lugares donde vive un cambio:

```
carpeta de trabajo  --git add-->  área de preparación (staged)  --git commit-->  historial  --git push-->  GitHub
```

### Commit con descripción extendida

```bash
git commit -m "docs: agrega README inicial" -m "Incluye el problema, la solución y el estado del proyecto"
# El primer -m es el título; los siguientes son el cuerpo del mensaje
```

### Prefijos para mensajes de commit (Conventional Commits)

| Prefijo | Cuándo usarlo |
|---|---|
| `feat:` | Funcionalidad nueva |
| `fix:` | Corrección de un error |
| `docs:` | Cambios solo de documentación |
| `style:` | Formato o estilos, sin cambiar la lógica |
| `refactor:` | Reorganizar código sin cambiar lo que hace |
| `test:` | Agregar o corregir pruebas |
| `chore:` | Mantenimiento (por ejemplo, `.gitignore`) |

---

## 4. Ver qué pasó

```bash
git status                       # Estado actual: qué cambió y qué está preparado
git status -s                    # Lo mismo, en formato corto
git diff                         # Cambios que aún NO están preparados
git diff --staged                # Cambios que YA están preparados para el commit
git log --oneline                # Historial resumido, un commit por línea
git log --oneline --graph --all  # Historial con el dibujo de las ramas
git show abc1234                 # Detalle de un commit concreto (usa su código corto)
```

---

## 5. Deshacer cosas

```bash
git restore --staged archivo     # Saca un archivo del área de preparación (no toca su contenido)
git restore --staged .           # Saca TODOS los archivos de la preparación
git restore archivo              # ⚠️ Descarga tus cambios en el archivo y lo deja como en el último commit
git restore archivo              # Si borraste el archivo, también lo recupera

git commit --amend -m "nuevo mensaje"   # Corrige el ÚLTIMO commit (solo si aún no hiciste push)

git reset --soft HEAD~1          # Deshace el último commit; los cambios quedan preparados
git reset HEAD~1                 # Deshace el último commit; los cambios quedan sin preparar
git reset --hard HEAD~1          # ⚠️ Deshace el último commit Y borra sus cambios

git revert abc1234               # Crea un commit nuevo que deshace otro (seguro si ya hiciste push)
```

Regla práctica: si el commit **ya está en GitHub**, usa `revert`. Reescribir historia publicada (`amend`, `reset`) causa problemas a tus compañeros.

---

## 6. Ramas (trabajar sin romper main)

```bash
git branch                       # Lista las ramas locales (la actual lleva *)
git branch -a                    # Lista también las ramas remotas
git switch -c feat/login         # Crea una rama nueva y cambia a ella
git switch main                  # Cambia a otra rama existente
git push -u origin feat/login    # Sube la rama a GitHub por primera vez
git merge feat/login             # Une la rama indicada con la rama en la que estás
git branch -d feat/login         # Borra la rama local ya unida
git push origin --delete feat/login   # Borra la rama en GitHub
```

Flujo típico de una funcionalidad:

```bash
git switch main
git pull
git switch -c feat/login         # Trabajas, haces commits...
git push -u origin feat/login    # Subes la rama y abres un Pull Request en GitHub
```

---

## 7. Sincronizar con GitHub

```bash
git fetch                        # Descarga lo nuevo SIN mezclarlo con tus archivos
git pull                         # fetch + merge: trae y mezcla los cambios del remoto
git pull --no-rebase             # Igual, unificando con un merge (útil si Git pide elegir cómo)
git push                         # Sube tus commits
git push -u origin rama          # Primera subida de una rama nueva
git remote -v                    # Muestra la dirección del remoto
git remote set-url origin NUEVA_URL   # Cambia la dirección (por ejemplo, si cambiaste de usuario)
```

---

## 8. Conflictos (cuando dos personas cambian las mismas líneas)

1. Git marca el archivo con estas señales:

```
<<<<<<< HEAD
tu versión
=======
la versión del otro
>>>>>>> rama
```

2. Edita el archivo, deja la versión correcta y **borra las tres marcas**.
3. Termina el proceso:

```bash
git add archivo-resuelto
git commit                       # Git propone un mensaje; acéptalo
git merge --abort                # Si prefieres cancelar todo y volver a como estabas
```

---

## 9. Guardar cambios a medias (stash)

```bash
git stash                        # Guarda tus cambios sin commit y deja la carpeta limpia
git stash list                   # Muestra lo guardado
git stash pop                    # Recupera los últimos cambios guardados
```

Útil cuando necesitas cambiar de rama o hacer `git pull` y aún no quieres hacer commit.

---

## 10. Ignorar y mover archivos

```bash
git check-ignore -v ruta/archivo        # Comprueba si el .gitignore ignora un archivo (y por qué regla)
git rm --cached archivo                 # Deja de seguir un archivo SIN borrarlo de tu disco
git rm -r --cached carpeta/             # Lo mismo para una carpeta (ej. .vs)
git rm archivo                          # ⚠️ Borra el archivo del disco Y del seguimiento
git mv viejo.txt nuevo.txt              # Renombra o mueve un archivo conservando su historial
```

Recuerda: el `.gitignore` solo afecta a archivos que Git **aún no sigue**. Si ya estaban subidos, primero usa `git rm --cached`.

---

## 11. Versiones (tags)

```bash
git tag -a v0.1.0 -m "Primer hito: diseño completo"   # Marca una versión
git push origin v0.1.0                                # Sube la etiqueta a GitHub
git tag                                               # Lista las etiquetas
```

---

## 12. Cuando algo sale mal (mensajes frecuentes)

| Mensaje | Qué significa | Solución |
|---|---|---|
| `rejected ... remote contains work that you do not have locally` | GitHub tiene commits que tú no | `git pull` y luego `git push` |
| `LF will be replaced by CRLF` | Aviso de saltos de línea en Windows | Es solo una advertencia; ignórala o usa `core.autocrlf true` |
| `nothing to commit, working tree clean` | No hay cambios por guardar | Todo está al día |
| `Your branch is ahead of 'origin/main' by N commits` | Tienes commits locales sin subir | `git push` |
| `CONFLICT (content): Merge conflict in ...` | Dos cambios chocan en el mismo archivo | Ver sección 8 |
| `fatal: not a git repository` | Estás fuera de la carpeta del proyecto | Entra a la raíz del repositorio |

---

## Orden recomendado de cada jornada

```bash
git pull                         # Al empezar
# ... trabajas ...
git status                       # Revisas qué cambió
git add archivo1 archivo2        # Preparas solo lo de una misma tarea
git commit -m "tipo: descripción"
git pull                         # Antes de subir, por si alguien subió algo
git push
```