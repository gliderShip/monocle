require 'dedent'

module Brisk
  module Models
    module Mailer extend self
      def user_invite!(invite)
        Mail.deliver do
          from    'Quid Fit? <pulse@harlembiospace.com>'
          to      invite.email
          subject "An invitation to join Quid Fit? from #{invite.user_name}."
          body    <<-EOF.dedent
            Përshëndetje,

            #{invite.user_name} ju fton ti bashkoheni Masës-Kritike, nje website i dedikuar ndarjes ne kohë reale te temave, artikujve, informacioneve dhe materialeve me interesante.
            Per tu informuar dhe debatuar ne kohe reale mbi aktualitetin, politiken, ekonomin dhe gjithcka tjeter.

            Për të mësuar më shumë, hidhi një sy:

            http://glidership.com:3000/claim/#{invite.code}

            Gjithë te mirat,
            
            Masa-Kritike

        end
      end

      def create_and_deliver_password_change!(user, password)
        Mail.deliver do
          from    'Masa-Kritike <glidership@hotmail.com>'
          to      user.email
          subject 'Ndryshoni Fjalëkalimin'
          body    <<-EOF.dedent
            Hi there,

            A password change was requested on your behalf. You can login with the password below.

            New Password: #{password}

            Please change the password after logging in.

            Thanks,
            Admin
          EOF
        end
      end

      def user_activate!(user)
        Mail.deliver do
          from    'Quid Fit? <glidership@hotmail.com>'
          to      user.email
          subject 'Welcome to Quid Fit?!'
          body    <<-EOF.dedent
            Hi there,

            Good news! #{user.parent_name || 'Admin'} has activated your Quid Fit? account.

            Thanks,
            Admin
          EOF
        end
      end

      def feedback!(text, email = nil)
        Mail.deliver do
          from    'Quid Fit? <glidership@hotmail.com>'
          to      'glidership@hotmail.com'
          subject 'Quid Fit? Sugjerime'
          reply_to email if email.present?
          body     text

          charset = 'UTF-8'
          content_transfer_encoding = '8bit'
        end
      end
    end
  end
end