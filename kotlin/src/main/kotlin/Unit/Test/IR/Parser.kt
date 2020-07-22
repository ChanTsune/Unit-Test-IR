package Unit.Test.IR

import kastree.ast.psi.Converter
import org.jetbrains.kotlin.cli.common.CLIConfigurationKeys
import org.jetbrains.kotlin.cli.common.messages.MessageRenderer.PLAIN_RELATIVE_PATHS
import org.jetbrains.kotlin.cli.common.messages.PrintingMessageCollector
import org.jetbrains.kotlin.cli.jvm.compiler.EnvironmentConfigFiles
import org.jetbrains.kotlin.cli.jvm.compiler.KotlinCoreEnvironment
import org.jetbrains.kotlin.com.intellij.openapi.util.Disposer
import org.jetbrains.kotlin.com.intellij.psi.PsiElement
import org.jetbrains.kotlin.com.intellij.psi.PsiErrorElement
import org.jetbrains.kotlin.com.intellij.psi.PsiManager
import org.jetbrains.kotlin.com.intellij.testFramework.LightVirtualFile
import org.jetbrains.kotlin.config.CompilerConfiguration
import org.jetbrains.kotlin.idea.KotlinFileType
import org.jetbrains.kotlin.psi.KtFile

open class Parser(val converter: Converter = Converter) {
    protected val proj by lazy {
        val disposable = Disposer.newDisposable()
        val configuration = CompilerConfiguration()
        configuration.put(
                CLIConfigurationKeys.MESSAGE_COLLECTOR_KEY,
                PrintingMessageCollector(System.err, PLAIN_RELATIVE_PATHS, false))
        val env =
                KotlinCoreEnvironment.createForProduction(
                        disposable, configuration, EnvironmentConfigFiles.JVM_CONFIG_FILES)
        env.project
    }

    fun parseFile(code: String, throwOnError:Boolean=true) = converter.convertFile(parsePsiFile(code).also { file ->

        if (throwOnError) file.children.filterIsInstance<PsiErrorElement>().let {
            if (it.isNotEmpty()) throw ParseError(file, it)
        }
    })

    fun parsePsiFile(code: String) =
            PsiManager.getInstance(proj).findFile(LightVirtualFile("temp.kt", KotlinFileType.INSTANCE, code)) as KtFile

    data class ParseError(
            val file: KtFile,
            val errors: List<PsiErrorElement>
    ) : IllegalArgumentException("Failed with ${errors.size} errors, first: ${errors.first().errorDescription}")

    companion object : Parser() {
        init {
            // To hide annoying warning on Windows
            System.setProperty("idea.use.native.fs.for.win", "false")
        }
    }
}

