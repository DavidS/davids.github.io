---
title: 'DNSSec update'
tags: hosting dnssec security
---

# A little lesson in humility

Actually getting my [registrar](http://www.hetzner.de) to sign off on my zone
has proven to be a little more involved than sending in the finished DS
records. Truth be told, hetzner does not support DNSSEC *AT ALL*:

> Sehr geehrte Damen und Herren,
>
> vielen Dank für Ihr Interesse an DNSSEC. Wir halten DNSSEC für ein
> nützliches Feature um das Sicherheitsniveau im DNS-Bereich zu erhöhen.
>
> Die Implementierung von DNSSEC erfordert allerdings weitreichende
> Anpassungen und Erweiterungen an mehreren Systemen. So muss von unseren
> Administrationsoberflächen über die Schnittstellen zu den jeweiligen
> Domain-Vergabestellen bis hin zu unseren Nameservern DNSSEC integriert
> werden.
>
> Leider können wir Ihnen daher DNSSEC zum aktuellen Zeitpunkt nicht
> anbieten. Sobald es zu diesem Thema Neuigkeiten gibt, werden wir Sie
> über unseren Newsletter informieren.
>
> Mit freundlichen Grüßen / Best Regards

Which roughly translates to "DNSSEC is truly a useful feature, but much too
complex, so stop bothering us about it and check out our newsletter, where we
will inform the sheeple when they can again feed from our hand."

Which translates precisely to "Ok, then I'm gonna find me a different DNS
registrar, because even when I go directly to nic.at, I'll be better off
security- and feature-wise."
