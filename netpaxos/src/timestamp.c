#include <pif_plugin.h>
#include <nfp.h>

__gpr uint32_t timestamp_high, timestamp_low;


int pif_plugin_get_forwarding_start_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_FORWARD;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->fsl = timestamp_low;
    paxos->fsh = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_get_forwarding_end_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_FORWARD;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->fel = timestamp_low;
    paxos->feh = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_get_coordinator_start_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_DROP;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->csl = timestamp_low;
    paxos->csh = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_get_coordinator_end_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_DROP;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->cel = timestamp_low;
    paxos->ceh = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_get_acceptor_start_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_DROP;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->asl = timestamp_low;
    paxos->ash = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_get_acceptor_end_time(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data)
{
    PIF_PLUGIN_paxos_T *paxos;
    timestamp_low = local_csr_read(local_csr_timestamp_low);
    timestamp_high = local_csr_read(local_csr_timestamp_high);

    if (! pif_plugin_hdr_paxos_present(headers)) {
        return PIF_PLUGIN_RETURN_DROP;
    }

    paxos = pif_plugin_hdr_get_paxos(headers);

    paxos->ael = timestamp_low;
    paxos->aeh = timestamp_high;
    return PIF_PLUGIN_RETURN_FORWARD;
}
