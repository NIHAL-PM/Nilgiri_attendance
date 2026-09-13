allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Some third-party Flutter plugins still declare Java 8 source compatibility.
// Keep their Kotlin tasks on the same bytecode target; modern Kotlin Gradle
// Plugin versions reject mixed Java/Kotlin targets.
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(
            when (project.name) {
                "app", "camera_android_camerax", "flutter_plugin_android_lifecycle" ->
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                "google_mlkit_commons", "google_mlkit_face_detection", "jni", "jni_flutter" ->
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
                else -> org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
            },
        )
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
