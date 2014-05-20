require 'dedent'

module Brisk
  module Models
    module Mailer extend self
      def user_invite!(invite)
        Mail.deliver do
          from    'albanania <mail@albanania.com>'
          to      invite.email
          subject "#{invite.user_name} ju fton personalisht tek albanania.com"
          body    <<-EOF.dedent
            Përshëndetje,

            #{invite.user_name} ju fton ti bashkoheni albanania.com, nje website i dedikuar ndarjes ne kohë reale te temave, artikujve, informacioneve dhe materialeve me interesante.
            Per tu informuar dhe debatuar ne kohe reale mbi aktualitetin, politiken, ekonomin dhe gjithcka tjeter.

            Për të mësuar më shumë, hidhi një sy:

            http://albanania.com/claim/#{invite.code}

            Gjithë te mirat,
            
            albanania.com

        end
      end

      def create_and_deliver_password_change!(user, password)
        Mail.deliver do
          from    'albanania <mail@albanania.com>'
          to      user.email
          subject 'Ndryshoni Fjalëkalimin'
          body    <<-EOF.dedent
            Përshëndetje,

            Keni kërkuar ndryshimin e fjalëkalimit. Ju mund të identifikoheni me fjalëkalimin më poshtë.

            Fjalëkalimi i Ri: #{password}

            Ju lutemi të ndryshojni fjalëkalimin menjëherë pasi te kyçeni!

            Gjithë te mirat,

            albanania.com
          EOF
        end
      end

      def user_activate!(user)
        Mail.deliver do
          from    'albanania <mail@albanania.com>'
          to      user.email
          subject 'Mirë se vini tek albanania.com!'
          body    <<-EOF.dedent
            Përshëndetje,

            Lajme të mira! #{user.parent_name || 'Admin'} ka aktivizuar llogarinë tuaj tek albanania.com!

            Gjithë te mirat,

            albanania.com
          EOF
        end
      end

      def feedback!(text, email = nil)
        Mail.deliver do
          from    'albanania <mail@albanania.com>'
          to      'glidership@hotmail.com'
          subject 'albanania.com Sugjerime'
          reply_to email if email.present?
          body     text

          charset = 'UTF-8'
          content_transfer_encoding = '8bit'
        end
      end
    end
  end
end