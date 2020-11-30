import org.gradle.api.publish.maven.MavenPom


group = "dev.tsune"
version = "1.0.0-beta1"

plugins {
    // Apply the Kotlin JVM plugin to add support for Kotlin.
    id("org.jetbrains.kotlin.jvm") version "1.4.0"

    // Apply plugin for document generation
    id("org.jetbrains.dokka") version "1.4.0-rc"


    id("com.jfrog.bintray") version "1.8.5"

    // Apply the java-library plugin for API and implementation separation.
    id("java-library")

    // Apply library publish plugin
    id("maven-publish")
}

repositories {
    // Use jcenter for resolving dependencies.
    // You can declare any Maven/Ivy/file repository here.
    jcenter()
}

dependencies {
    // Align versions of all Kotlin components
    implementation(platform("org.jetbrains.kotlin:kotlin-bom"))

    // Use the Kotlin test library.
    testImplementation("org.jetbrains.kotlin:kotlin-test")

    // Use the Kotlin JUnit integration.
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit")
}

kotlin {
    explicitApiWarning()
}

//sources
val sourcesJar by tasks.creating(Jar::class) {
    from(sourceSets.main.get().allSource)
    archiveClassifier.set("sources")
}

tasks.dokkaHtml.configure {
    outputDirectory = "$buildDir/dokka/html"
}
tasks.dokkaGfm.configure {
    outputDirectory = "$buildDir/dokka/gfm"
}
tasks.dokkaJavadoc.configure {
    outputDirectory = "$buildDir/dokka/javadoc"
}
tasks.dokkaJekyll.configure {
    outputDirectory = "$buildDir/dokka/jekyll"
}

// Create dokka Jar task from dokka task output
val dokkaJar by tasks.creating(Jar::class) {
    group = JavaBasePlugin.DOCUMENTATION_GROUP
    description = "Assembles Kotlin docs with Dokka"
    archiveClassifier.set("javadoc")
    // dependsOn(tasks.dokka) not needed; dependency automatically inferred by from(tasks.dokka)
    from(tasks.dokkaHtml)
}

//publications
val snapshot = "snapshot"
val release = "release"

publishing {
    fun MavenPom.initPom() {
        name.set("ktPyString")
        description.set("Python like String method in Kotlin")
        url.set("https://github.com/ChanTsune/ktPyString")

        licenses {
            license {
                name.set("MIT")
                url.set("https://github.com/ChanTsune/ktPyString/blob/master/LICENSE")
            }
        }
        scm {
            url.set("https://github.com/ChanTsune/ktPyString.git")
        }
    }
    publications {
        create<MavenPublication>(snapshot) {
            from(components["java"])
            artifact(dokkaJar)
            artifact(sourcesJar)
            artifactId = "ktPyString"
            version = "${project.version}-SNAPSHOT"

            pom.initPom()
        }
        create<MavenPublication>(release) {
            from(components["java"])
            artifact(dokkaJar)
            artifact(sourcesJar)
            artifactId = "ktPyString"
            version = "${project.version}"

            pom.initPom()
        }
    }
}


bintray {
    user = findProperty("bintray_user") as? String
    key = findProperty("bintray_key") as? String

    val isRelease = findProperty("release") == "true"

    publish = isRelease
    override = false

    setPublications(if (isRelease) release else snapshot)

//    dryRun = true

    with(pkg) {
        repo = "ktPyString"
        name = "ktPyString"
        setLicenses("MIT")
        setLabels("kotlin")
        websiteUrl = "https://github.com/ChanTsune/ktPyString"
        issueTrackerUrl = "https://github.com/ChanTsune/ktPyString/issues"
        vcsUrl = "https://github.com/ChanTsune/ktPyString.git"
        publicDownloadNumbers = true
        githubRepo = "ChanTsune/ktPyString"
        githubReleaseNotesFile = "README.md"

        with(version) {
            name = project.version.toString()
            vcsTag = project.version.toString()
        }
    }
}
