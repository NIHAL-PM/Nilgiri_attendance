import org.gradle.api.JavaVersion
import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Align JVM target compatibility between Java and Kotlin tasks across all
// subprojects. Modern Kotlin Gradle Plugin rejects mixed Java/Kotlin targets.
// We set both sourceCompatibility/targetCompatibility for Java tasks AND
// jvmTarget for Kotlin tasks to the same value per project, eliminating
// mismatches like tflite_flutter's Java 11 vs Kotlin 1.8.
subprojects {
    val (javaVersion, kotlinJvmTarget) =
        when (project.name) {
            "app", "camera_android_camerax", "flutter_plugin_android_lifecycle" ->
                JavaVersion.VERSION_17 to JvmTarget.JVM_17
            else ->
                JavaVersion.VERSION_11 to JvmTarget.JVM_11
        }

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = javaVersion.toString()
        targetCompatibility = javaVersion.toString()
    }

    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(kotlinJvmTarget)
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
