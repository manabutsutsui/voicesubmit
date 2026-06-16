import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LegalSection(
                    title: "はじめに",
                    """
                    本利用規約（以下「本規約」）は、VoiceSubmit（以下「本アプリ」）の利用条件を定めるものです。本アプリをご利用いただくことで、本規約に同意したものとみなします。
                    """)
                LegalSection(
                    title: "サービスの概要",
                    """
                    本アプリは、ユーザーが音声メッセージを録音・投稿し、他のユーザーがそれを匿名で受け取ることができるサービスです。投稿された音声はランダムに配信されます。
                    """)
                LegalSection(
                    title: "利用条件",
                    """
                    • 本アプリは個人の非商業的な利用に限り使用できます。
                    • 本アプリを利用するにあたり、適用されるすべての法律および規制を遵守してください。
                    • 本アプリを通じて投稿したコンテンツに対する責任はユーザー自身が負います。
                    """)
                LegalSection(
                    title: "禁止行為",
                    """
                    以下の行為を禁止します。

                    • 他者を傷つける、脅迫する、または嫌がらせをするコンテンツの投稿
                    • 差別的・侮辱的・わせつなコンテンツの投稿
                    • 個人情報（氏名・住所・電話番号など）を含む音声の投稿
                    • スパムや広告目的のコンテンツの投稿
                    • 著作権その他の知的財産権を侵害するコンテンツの投稿
                    • 本アプリのシステムに対する不正アクセスや改ざん
                    """)
                LegalSection(
                    title: "コンテンツの取り扱い",
                    """
                    投稿された音声は、サービス運営のためにサーバーに保存されます。不適切なコンテンツとして通報されたものは、審査のうえ削除される場合があります。
                    """)
                LegalSection(
                    title: "免責事項",
                    """
                    本アプリは現状有姿で提供されます。サービスの中断・終了、またはコンテンツの損失について、開発者は一切の責任を負いません。ユーザー間のやり取りによって生じたいかなる損害についても、開発者は責任を負いません。
                    """)
                LegalSection(
                    title: "規約の変更",
                    """
                    本規約は予告なく変更される場合があります。変更後も本アプリを継続してご利用いただいた場合、変更後の規約に同意したものとみなします。
                    """)
                LegalSection(title: "最終更新日", "2026年6月15日")
            }
            .padding()
        }
        .navigationTitle("利用規約")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommunityGuidelinesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LegalSection(
                    title: "コミュニティの目的",
                    """
                    VoiceSubmit は、誰かの声や想いをそっと届けるための場所です。互いを尊重し、安心して声を届け合えるコミュニティを目指しています。
                    """)
                LegalSection(
                    title: "大切にしてほしいこと",
                    """
                    • 相手への敬意を忘れずに
                    • 誰かの心に届くような、温かいメッセージを
                    • 聞いた声を大切に受け取ってください
                    """)
                LegalSection(
                    title: "禁止されているコンテンツ",
                    """
                    以下のコンテンツは投稿しないでください。

                    【不適切なコンテンツ】
                    性的・暴力的・差別的な表現を含む音声

                    【ハラスメント】
                    特定の個人または集団を標的にした攻撃・侮辱・脅迫

                    【スパム】
                    宣伝・勧誘・同一内容の繰り返し投稿

                    【プライバシーの侵害】
                    他者の個人情報（氏名・住所・連絡先など）を含む音声

                    【違法なコンテンツ】
                    法律に違反する内容、または違法行為を助長するもの
                    """)
                LegalSection(
                    title: "通報について",
                    """
                    不適切だと感じた音声は、再生画面右上の旗アイコンから通報できます。通報内容は運営が確認し、ガイドライン違反と判断された場合は該当コンテンツを削除します。

                    通報は匿名で行われ、通報者の情報が投稿者に知らされることはありません。
                    """)
                LegalSection(
                    title: "ガイドライン違反について",
                    """
                    本ガイドラインに違反するコンテンツは予告なく削除されます。悪質な違反が繰り返される場合、利用制限を行うことがあります。
                    """)
                LegalSection(title: "最終更新日", "2026年6月15日")
            }
            .padding()
        }
        .navigationTitle("コミュニティガイドライン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LegalSection: View {
    let title: String
    let text: String

    init(title: String, _ text: String) {
        self.title = title
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
