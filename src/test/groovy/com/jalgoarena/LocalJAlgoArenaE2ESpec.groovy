package com.jalgoarena

import com.google.common.base.Charsets
import com.google.common.io.Resources
import groovy.json.StringEscapeUtils
import groovyx.net.http.ContentType
import groovyx.net.http.HttpResponseException
import groovyx.net.http.RESTClient
import spock.lang.Ignore
import org.slf4j.LoggerFactory
import spock.lang.Specification
import spock.lang.Unroll

class LocalJAlgoArenaE2ESpec extends Specification {

    static log = LoggerFactory.getLogger(LocalJAlgoArenaE2ESpec.class)

    static jalgoApiClient = new RESTClient("http://localhost:5001/")

    @Unroll
    @Ignore
    "User #username submits successfully #problemId problem solution in #language"(String problemId, String sourceFileName, String language, String username) {
        given: "User creates account if empty and log in"
            def user = createOrFindUser(username)
            def token = logInUser(username)

        and: "User judges solution for $problemId problem"
            def fileExtension = "java" == language ? "java" : "kt"
            def sourceCode = Resources.toString(Resources.getResource("$sourceFileName.$fileExtension"), Charsets.UTF_8)
            def judgeResult = judgeProblem(sourceCode, user, token, problemId, language)

        expect:
            token != null
            judgeResult != null
            judgeResult.submissionId != null
            judgeResult.problemId == problemId

        when: "We check user submissions"
            log.info("Step 4 - Check Submission for $problemId")
            sleep(1000)

            def submissionResult
            for (iteration in 1..20) {
                handleHttpException {
                    submissionResult = jalgoApiClient.get(
                            path: "/submissions/api/submissions/find/${user.id}/${judgeResult.submissionId}",
                            contentType: ContentType.JSON,
                            headers: ["X-Authorization": "Bearer ${token}"]
                    ).data
                }

                if (submissionResult != null && submissionResult.statusCode != "NOT_FOUND") {
                    break
                }
                log.info("No response, retrying [iteration=$iteration]")
                sleep(2000)
            }


        then: "We can see saved submission on user profile"
            submissionResult != null
            submissionResult.problemId == problemId
            submissionResult.elapsedTime > 0.0
            submissionResult.sourceCode == sourceCode
            submissionResult.statusCode == "ACCEPTED"
            submissionResult.language == language
            submissionResult.submissionId == judgeResult.submissionId
            submissionResult.errorMessage == null || submissionResult.errorMessage == ""

        where:
        problemId                   | sourceFileName            | language  | username
        "2-sum"                     | "TwoSum"                  | "java"    | "mikołaj"
        "fib"                       | "FibFast"                 | "java"    | "mikołaj"
        "stoi"                      | "MyStoi"                  | "java"    | "mikołaj"
        "word-ladder"               | "WordLadder"              | "java"    | "mikołaj"
        "is-string-unique"          | "IsStringUnique2"         | "java"    | "mikołaj"
        "check-perm"                | "CheckPerm"               | "java"    | "mikołaj"
        "palindrome-perm"           | "PalindromePerm"          | "java"    | "mikołaj"
        "one-away"                  | "OneAway"                 | "java"    | "mikołaj"
        "string-compress"           | "StringCompress"          | "java"    | "mikołaj"
        "rotate-matrix"             | "RotateMatrix"            | "java"    | "mikołaj"
        "zero-matrix"               | "ZeroMatrix"              | "java"    | "mikołaj"
        "remove-dups"               | "RemoveDups"              | "java"    | "mikołaj"
        "kth-to-last"               | "KThToLast"               | "java"    | "mikołaj"
        "string-rotation"           | "StringRotation"          | "java"    | "mikołaj"
        "sum-lists"                 | "SumLists"                | "java"    | "mikołaj"
        "sum-lists-2"               | "SumLists2"               | "java"    | "mikołaj"
        "palindrome-list"           | "PalindromeList"          | "java"    | "mikołaj"
        "binary-search"             | "BinarySearch"            | "java"    | "mikołaj"
        "delete-tail-node"          | "DeleteTailNode"          | "java"    | "mikołaj"
        "repeated-elements"         | "RepeatedElements"        | "java"    | "mikołaj"
        "first-non-repeated-char"   | "FirstNonRepeatedChar"    | "java"    | "mikołaj"
        "find-middle-node"          | "FindMiddleNode"          | "java"    | "mikołaj"
        "horizontal-flip"           | "HorizontalFlip"          | "java"    | "mikołaj"
        "vertical-flip"             | "VerticalFlip"            | "java"    | "mikołaj"
        "single-number"             | "SingleNumber"            | "java"    | "mikołaj"
        "preorder-traversal"        | "PreorderTraversal"       | "java"    | "mikołaj"
        "inorder-traversal"         | "InorderTraversal"        | "java"    | "mikołaj"
        "postorder-traversal"       | "PostorderTraversal"      | "java"    | "mikołaj"
        "height-binary-tree"        | "HeightOfBinaryTree"      | "java"    | "mikołaj"
        "sum-binary-tree"           | "SumBinaryTree"           | "java"    | "mikołaj"
        "insert-stars"              | "InsertStars"             | "java"    | "mikołaj"
        "transpose-matrix"          | "TransposeMatrix"         | "java"    | "mikołaj"
        "2-sum"                     | "TwoSum"                  | "kotlin"  | "julia"
        "fib"                       | "FibFast"                 | "kotlin"  | "julia"
        "stoi"                      | "MyStoi"                  | "kotlin"  | "julia"
        "word-ladder"               | "WordLadder"              | "kotlin"  | "julia"
        "is-string-unique"          | "IsStringUnique2"         | "kotlin"  | "julia"
        "check-perm"                | "CheckPerm"               | "kotlin"  | "julia"
        "palindrome-perm"           | "PalindromePerm"          | "kotlin"  | "julia"
        "one-away"                  | "OneAway"                 | "kotlin"  | "julia"
        "string-compress"           | "StringCompress"          | "kotlin"  | "julia"
        "rotate-matrix"             | "RotateMatrix"            | "kotlin"  | "julia"
        "zero-matrix"               | "ZeroMatrix"              | "kotlin"  | "julia"
        "remove-dups"               | "RemoveDups"              | "kotlin"  | "julia"
        "kth-to-last"               | "KThToLast"               | "kotlin"  | "julia"
        "string-rotation"           | "StringRotation"          | "kotlin"  | "julia"
        "sum-lists"                 | "SumLists"                | "kotlin"  | "julia"
        "sum-lists-2"               | "SumLists2"               | "kotlin"  | "julia"
        "palindrome-list"           | "PalindromeList"          | "kotlin"  | "julia"
        "binary-search"             | "BinarySearch"            | "kotlin"  | "julia"
        "delete-tail-node"          | "DeleteTailNode"          | "kotlin"  | "julia"
        "repeated-elements"         | "RepeatedElements"        | "kotlin"  | "julia"
        "first-non-repeated-char"   | "FirstNonRepeatedChar"    | "kotlin"  | "julia"
        "find-middle-node"          | "FindMiddleNode"          | "kotlin"  | "julia"
        "horizontal-flip"           | "HorizontalFlip"          | "kotlin"  | "julia"
        "vertical-flip"             | "VerticalFlip"            | "kotlin"  | "julia"
        "single-number"             | "SingleNumber"            | "kotlin"  | "julia"
        "preorder-traversal"        | "PreorderTraversal"       | "kotlin"  | "julia"
        "inorder-traversal"         | "InorderTraversal"        | "kotlin"  | "julia"
        "postorder-traversal"       | "PostorderTraversal"      | "kotlin"  | "julia"
        "height-binary-tree"        | "HeightOfBinaryTree"      | "kotlin"  | "julia"
        "sum-binary-tree"           | "SumBinaryTree"           | "kotlin"  | "julia"
        "insert-stars"              | "InsertStars"             | "kotlin"  | "julia"
        "transpose-matrix"          | "TransposeMatrix"         | "kotlin"  | "julia"
    }

    def createOrFindUser(String username) {
        handleHttpException {
            def users = jalgoApiClient.get(
                    path: "/auth/users",
                    contentType: ContentType.JSON
            ).data

            def user = users.find { it.username == username }

            if (user == null) {
                user = createUser(username)
            } else {
                log.info("User already created: ${user}")
            }

            user
        }
    }

    def judgeProblem(String sourceCode, user, token, problemId, language) {
        log.info("Step 3 - Judge Solution for $problemId")

        def judgeRequestJson = """{
    "sourceCode": "${StringEscapeUtils.escapeJava(sourceCode)}",
    "userId": "${user.id}",
    "language": "$language"
}
"""

        handleHttpException {
            jalgoApiClient.post(
                    path: "queue/api/problems/$problemId/publish",
                    body: judgeRequestJson,
                    requestContentType: ContentType.JSON,
                    contentType: ContentType.JSON,
                    headers: ["X-Authorization": "Bearer ${token}"]
            ).data
        }
    }

    def logInUser(username) {
        log.info("Step 2 - Log in")

        def loginRequestJson = """{
    "username": "$username",
    "password": "blabla"
}
"""

        handleHttpException {
            jalgoApiClient.post(
                    path: "auth/login",
                    body: loginRequestJson,
                    requestContentType: ContentType.JSON,
                    contentType: ContentType.JSON
            ).data.token
        }
    }

    def createUser(username) {
        def signupRequestJson = """{
  "username": "${username}",
  "password": "blabla",
  "email": "${username}@email.com",
  "region": "Kraków",
  "team": "Team A",
  "role": "USER"
}
"""

        log.info("Step 1 - Creating User")

        jalgoApiClient.post(
                path: "auth/signup",
                body: signupRequestJson,
                requestContentType: ContentType.JSON,
                contentType: ContentType.JSON
        ).data
    }

    def handleHttpException(block) {
        try {
            block()
        } catch (HttpResponseException e) {
            log.error("Status: ${e.response.status}, Message: ${e.response.data}")
            throw e
        }
    }
}
