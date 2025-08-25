// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// android/build.gradle.kts
buildscript {
    repositories {
        google()
        mavenCentral()
       
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.1")
        classpath(kotlin("gradle-plugin", "1.9.10"))
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()

    }
}


subprojects {
    // Relocate build directories to avoid conflicts
    val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
    project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


