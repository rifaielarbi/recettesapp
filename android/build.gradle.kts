allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Une seule déclaration de newBuildDir
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()

// Appliquer la nouvelle build directory au projet racine
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Tâche de nettoyage
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
