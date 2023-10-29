//
//  ApiWidget.swift
//  ApiWidget
//
//  Created by 陈东 on 14/10/2023.
//

import WidgetKit
import SwiftUI
import Intents

extension UserDefaults {
    static let storedRequestsKey = "storedRequests"
}

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), storedRequest: .init(request: .init(), name: "默认API试图"))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let entry = SimpleEntry(date: Date(), storedRequest: fetchData(name: configuration.name ?? ""))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), storedRequest: fetchData(name: configuration.name ?? ""))
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    func fetchData(name: String) -> StoredRequest {
        if let sharedDefaults = UserDefaults(suiteName: "group.cn.cdd.harFile"),
           let newStoredRequestsData = sharedDefaults.data(forKey: UserDefaults.storedRequestsKey),
           let decodedRequests = try? JSONDecoder().decode([StoredRequest].self, from: newStoredRequestsData) {
            let filteredRequest = decodedRequests.filter{ $0.name == name }
            if (!filteredRequest.isEmpty) {
                return filteredRequest.first!
            }
        }
        return .init(request: .init(), name: "默认API试图")
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let storedRequest: StoredRequest
}

struct ApiWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .center) {
                Text(entry.storedRequest.name)
                    .font(.title.bold())
                    .foregroundColor(.white)
                .padding(10)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            Spacer()
            
            HStack(alignment: .bottom) {
                Spacer()
                Text("API快捷执行")
                    .foregroundColor(.white)
                    .font(.caption2)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
//                    .background() {
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(.gray)
//                    }
//                Spacer()
            }
            .padding(5)
        }
        .frame(width: .infinity, height: .infinity)
        .background() {
            RoundedRectangle(cornerRadius: 0)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.8), Color.blue.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom))
        }
        .widgetURL(URL(string: "cn.cddchen.ApiBox://\(entry.storedRequest.name)"))
    }

    
}

struct ApiWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: "cn.cddchen.ApiBox.ApiWidget",
            intent: ConfigurationIntent.self,
            provider: Provider()) { entry in
                ApiWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("View Size Widget")
            .description("This is a demo widget.")
            .supportedFamilies([
                .systemSmall,
            ])
    }
}

struct ViewSizeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let request: Request = .init()
        let storedRequest: StoredRequest = .init(request: request, name: "电动车功率查询")
        ApiWidgetEntryView(entry: SimpleEntry(date: Date(), storedRequest: storedRequest))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
