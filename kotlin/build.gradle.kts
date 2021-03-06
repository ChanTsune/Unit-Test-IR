/*
 * This file was generated by the Gradle 'init' task.
 *
 * This generated file contains a sample Kotlin application project to get you started.
 */

plugins {
    // Apply the Kotlin JVM plugin to add support for Kotlin.
    kotlin("jvm") version "1.4.10"
    // Apply the kotlinx.serialization plugin
    kotlin("plugin.serialization") version "1.4.10"
    // Apply the application plugin to add support for building a CLI application.
    application
}

repositories {
    // Use jcenter for resolving dependencies.
    // You can declare any Maven/Ivy/file repository here.
    jcenter()
    maven("https://kotlin.bintray.com/kotlinx")
}

dependencies {
    // Align versions of all Kotlin components
    implementation(platform("org.jetbrains.kotlin:kotlin-bom"))
//    implementation(platform("org.jetbrains.kotlinx:kotlinx-io:0.1.16"))

    // kotlin ast libraries
    // [kastree](https://github.com/cretz/kastree)
    implementation("com.github.cretz.kastree:kastree-ast-jvm:0.4.0")
    implementation("com.github.cretz.kastree:kastree-ast-psi:0.4.0")
    implementation("com.github.cretz.kastree:kastree-ast-common:0.4.0")

    // kotlin enum extension
    // [kotlin-enum-extensions](https://github.com/ChanTsune/kotlin-enum-extensions)
    implementation(platform("com.github.chantsune:kotlin-enum-extensions:0.2.0"))

    // [kotlinx.serialization](https://github.com/Kotlin/kotlinx.serialization)
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.0.1")

    // [kaml](https://github.com/charleskorn/kaml)
    implementation("com.charleskorn.kaml:kaml:0.26.0")

    // [commons-lang](https://mvnrepository.com/artifact/commons-lang/commons-lang)
    implementation("commons-lang:commons-lang:2.6")

    // [kotlinx-cli](https://github.com/Kotlin/kotlinx-cli)
    implementation("org.jetbrains.kotlinx:kotlinx-cli:0.3")

    // Use the Kotlin test library.
    testImplementation("org.jetbrains.kotlin:kotlin-test")

    // Use the Kotlin JUnit integration.
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit")
}

application {
    // Define the main class for the application
    mainClassName = "unit.test.ir.AppKt"
}
