//
//  WorkoutBenchmark.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 2/22/26.
//

import Foundation

struct WorkoutBenchmark {

    // MARK: - Configuration
    static let dataSizes = [100, 1_000, 10_000]
    static let runsPerTest = 5

    static let exercises = [
        "Bench Press", "Squat", "Deadlift", "Overhead Press",
        "Pull Up", "Barbell Row", "Leg Press", "Incline Bench",
        "Dumbbell Curl", "Tricep Pushdown", "Lat Pulldown", "Cable Fly"
    ]

    static let muscleGroups = ["Chest", "Back", "Legs", "Arms", "Shoulders", "Core"]

    // MARK: - Entry Point
    static func run() {
        print("\n")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║           WORKOUTTRACKER PERFORMANCE BENCHMARK               ║")
        print("║                  \(formattedDate())                          ║")
        print("║              Averaged over \(runsPerTest) runs per test      ║")
        print("╚══════════════════════════════════════════════════════════════╝")

        var results: [BenchmarkResult] = []

        for size in dataSizes {
            print("\n▶ Generating \(size) synthetic entries...")
            let entries = generateEntries(count: size)
            let result = runAllTests(entries: entries, size: size)
            results.append(result)
        }

        printSummaryReport(results: results)
    }

    // MARK: - Synthetic Data Generation
    static func generateEntries(count: Int) -> [WorkoutEntry] {
        var entries: [WorkoutEntry] = []
        entries.reserveCapacity(count)

        let calendar = Calendar.current
        let now = Date()

        for i in 0..<count {
            let daysBack = Double(i % 730)
            let hoursOffset = Double.random(in: 0..<24)
            let date = calendar.date(
                byAdding: .second,
                value: -Int(daysBack * 86400 + hoursOffset * 3600),
                to: now
            ) ?? now

            let exercise = exercises[i % exercises.count]
            let muscleGroup = muscleGroups[i % muscleGroups.count]

            let baseWeight: Double
            switch exercise {
            case "Squat":        baseWeight = 135
            case "Deadlift":     baseWeight = 185
            case "Bench Press":  baseWeight = 95
            default:             baseWeight = Double.random(in: 20...135)
            }

            let progressFactor = 1.0 + (Double(i) / Double(count)) * 0.5
            let weight = (baseWeight * progressFactor).rounded()

            entries.append(WorkoutEntry(
                date: date,
                muscleGroup: muscleGroup,
                exercise: exercise,
                weight: weight,
                reps: Int.random(in: 3...12)
            ))
        }

        return entries.sorted { $0.date < $1.date }
    }

    // MARK: - Test Runner
    static func runAllTests(entries: [WorkoutEntry], size: Int) -> BenchmarkResult {
        let loadTime     = benchmarkLoadTime(entries: entries)
        let queryResults = benchmarkQueries(entries: entries)
        let graphResults = benchmarkGraphRendering(entries: entries)

        return BenchmarkResult(
            size:         size,
            loadTimeMs:   loadTime,
            queryResults: queryResults,
            graphResults: graphResults
        )
    }

    // MARK: - Test 1: Load Time (encode → UserDefaults → decode)
    static func benchmarkLoadTime(entries: [WorkoutEntry]) -> Double {
        var times: [Double] = []

        for _ in 0..<runsPerTest {
            let key = "benchmark_temp_\(UUID().uuidString)"
            let start = Date()

            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: key)
            }

            if let data = UserDefaults.standard.data(forKey: key),
               let _ = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {}

            times.append(Date().timeIntervalSince(start) * 1000)
            UserDefaults.standard.removeObject(forKey: key)
        }

        return average(times)
    }

    // MARK: - Test 2: Query / Filter Time
    static func benchmarkQueries(entries: [WorkoutEntry]) -> [QueryResult] {
        var results: [QueryResult] = []
        let calendar = Calendar.current

        results.append(averagedTime(label: "Filter by exercise (Bench Press)") {
            _ = entries.filter { $0.exercise.lowercased().contains("bench") }
        })

        results.append(averagedTime(label: "Filter by muscle group (Chest)") {
            _ = entries.filter { $0.muscleGroup == "Chest" }
        })

        results.append(averagedTime(label: "Sort by date descending") {
            _ = entries.sorted { $0.date > $1.date }
        })

        results.append(averagedTime(label: "Max weight per exercise") {
            _ = Dictionary(grouping: entries, by: { $0.exercise })
                .mapValues { $0.map { $0.weight }.max() ?? 0 }
        })

        results.append(averagedTime(label: "Unique exercise count") {
            _ = Set(entries.map { $0.exercise.lowercased() }).count
        })

        results.append(averagedTime(label: "Monthly unique workout days") {
            let month = calendar.component(.month, from: Date())
            let year  = calendar.component(.year,  from: Date())
            _ = Set(
                entries
                    .filter {
                        calendar.component(.month, from: $0.date) == month &&
                        calendar.component(.year,  from: $0.date) == year
                    }
                    .map { calendar.startOfDay(for: $0.date) }
            ).count
        })

        results.append(averagedTime(label: "Big Three combined max weight") {
            let s = entries.filter { $0.exercise.lowercased().contains("squat") }.map { $0.weight }.max() ?? 0
            let b = entries.filter { $0.exercise.lowercased().contains("bench") }.map { $0.weight }.max() ?? 0
            let d = entries.filter { $0.exercise.lowercased().contains("deadlift") }.map { $0.weight }.max() ?? 0
            _ = s + b + d
        })

        return results
    }

    // MARK: - Test 3: Graph Rendering (mirrors WorkoutChartView exactly)
    static func benchmarkGraphRendering(entries: [WorkoutEntry]) -> [GraphResult] {
        var results: [GraphResult] = []

        let exercisesToTest = ["Bench Press", "Squat", "Deadlift"]

        for exercise in exercisesToTest {
            let label = "Chart data for \(exercise)"

            let chartEntries = Array(
                entries
                    .filter { $0.exercise == exercise }
                    .sorted { $0.date < $1.date }
                    .suffix(25)
            )

            let result = averagedTime(label: label) {
                _ = Array(chartEntries.enumerated()).map { index, entry in
                    (index: index, date: entry.date, weight: entry.weight, reps: entry.reps)
                }
            }

            let inputCount = entries.filter { $0.exercise == exercise }.count
            results.append(GraphResult(
                label:          label,
                timeMs:         result.timeMs,
                inputCount:     inputCount,
                outputCount:    chartEntries.count,
                compressionPct: inputCount == 0 ? 0 : Double(chartEntries.count) / Double(inputCount) * 100
            ))
        }

        return results
    }

    // MARK: - Timing Helpers
    static func averagedTime(label: String, block: () -> Void) -> QueryResult {
        var times: [Double] = []
        for _ in 0..<runsPerTest {
            let start = Date()
            block()
            times.append(Date().timeIntervalSince(start) * 1000)
        }
        return QueryResult(label: label, timeMs: average(times))
    }

    static func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    // MARK: - Report Printer
    static func printSummaryReport(results: [BenchmarkResult]) {
        print("\n")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║                    BENCHMARK RESULTS                         ║")
        print("╚══════════════════════════════════════════════════════════════╝")

        for result in results {
            print("\n┌─────────────────────────────────────────────────────────────")
            print("│  DATASET SIZE: \(result.size) entries")
            print("├─────────────────────────────────────────────────────────────")

            print("│")
            print("│  📦 LOAD TIME (encode + UserDefaults write + decode)")
            print("│     \(formatMs(result.loadTimeMs))  (avg of \(runsPerTest) runs)")

            print("│")
            print("│  🔍 QUERY TIMES  (avg of \(runsPerTest) runs each)")
            for q in result.queryResults {
                let bar = progressBar(value: q.timeMs, max: 50)
                print("│     \(q.label.padding(toLength: 38, withPad: " ", startingAt: 0)) \(formatMs(q.timeMs))  \(bar)")
            }
            let totalQueryTime = result.queryResults.map { $0.timeMs }.reduce(0, +)
            print("│     ─────────────────────────────────────────────────────")
            print("│     Total query time (all award checks combined):  \(formatMs(totalQueryTime))")

            print("│")
            print("│  📈 CHART RENDERING (same logic as WorkoutChartView, capped at 25 pts)")
            for g in result.graphResults {
                print("│     \(g.label.padding(toLength: 28, withPad: " ", startingAt: 0)) \(formatMs(g.timeMs))  [\(g.inputCount) total → \(g.outputCount) shown, \(String(format: "%.1f", g.compressionPct))% retained]")
            }

            print("└─────────────────────────────────────────────────────────────")
        }

        print("\n┌─────────────────────────────────────────────────────────────")
        print("│  📊 SCALING SUMMARY")
        print("│")
        print("│  Metric               100       1,000     10,000")
        print("│  ─────────────────────────────────────────────────")

        let loadTimes = results.map { $0.loadTimeMs }
        print("│  Load time        \(padMs(loadTimes[0]))    \(padMs(loadTimes[1]))    \(padMs(loadTimes[2]))")

        for qi in 0..<(results.first?.queryResults.count ?? 0) {
            let label = results[0].queryResults[qi].label
            let short = String(label.prefix(18)).padding(toLength: 18, withPad: " ", startingAt: 0)
            let t0 = results[0].queryResults[qi].timeMs
            let t1 = results[1].queryResults[qi].timeMs
            let t2 = results[2].queryResults[qi].timeMs
            print("│  \(short)   \(padMs(t0))    \(padMs(t1))    \(padMs(t2))")
        }

        print("└─────────────────────────────────────────────────────────────")
        print("\n✅ Benchmark complete.\n")
    }

    // MARK: - Formatting Helpers
    static func formatMs(_ ms: Double) -> String {
        if ms < 1.0 {
            return String(format: "%.3f ms", ms)
        } else if ms < 100 {
            return String(format: "%.2f ms ", ms)
        } else {
            return String(format: "%.1f ms  ", ms)
        }
    }

    static func padMs(_ ms: Double) -> String {
        formatMs(ms).padding(toLength: 10, withPad: " ", startingAt: 0)
    }

    static func progressBar(value: Double, max: Double) -> String {
        let filled = min(Int((value / max) * 10), 10)
        let empty = 10 - filled
        return "[" + String(repeating: "█", count: filled) + String(repeating: "░", count: empty) + "]"
    }

    static func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy  HH:mm"
        return f.string(from: Date())
    }
}

// MARK: - Result Models
struct BenchmarkResult {
    let size:         Int
    let loadTimeMs:   Double
    let queryResults: [QueryResult]
    let graphResults: [GraphResult]
}

struct QueryResult {
    let label:  String
    let timeMs: Double
}

struct GraphResult {
    let label:          String
    let timeMs:         Double
    let inputCount:     Int
    let outputCount:    Int
    let compressionPct: Double
}
